defmodule Makeup.Lexers.MakeupPrisma do
  @moduledoc """
  A `makeup` lexer for Prisma.
  """

  import Makeup.Lexer.Combinators
  import Makeup.Lexer.Groups
  import NimbleParsec

  @behaviour Makeup.Lexer

  @impl Makeup.Lexer
  def lex(text, opts \\ []) do
    group_prefix = Keyword.get(opts, :group_prefix, random_prefix(10))
    {:ok, tokens, "", _, _, _} = root(text)

    tokens
    |> postprocess([])
    |> match_groups(group_prefix)
  end

  @impl Makeup.Lexer
  def postprocess(tokens, _opts \\ []), do: tokens

  @impl Makeup.Lexer
  defgroupmatcher(:match_groups,
    parentheses: [
      open: [[{:punctuation, %{language: :prisma}, "("}]],
      close: [[{:punctuation, %{language: :prisma}, ")"}]]
    ],
    list: [
      open: [
        [{:punctuation, %{language: :prisma}, "["}]
      ],
      close: [
        [{:punctuation, %{language: :prisma}, "]"}]
      ]
    ],
    curly: [
      open: [
        [{:punctuation, %{language: :prisma}, "{"}]
      ],
      close: [
        [{:punctuation, %{language: :prisma}, "}"}]
      ]
    ]
  )

  # Codepoints
  @horizontal_tab 0x0009
  @newline 0x000A
  @carriage_return 0x000D
  @space 0x0020
  @unicode_bom 0xFEFF

  any_unicode = utf8_char([])

  unicode_bom = ignore(utf8_char([@unicode_bom]))

  whitespace =
    ascii_string(
      [
        @horizontal_tab,
        @space
      ],
      min: 1
    )
    |> token(:whitespace)

  line_terminator =
    choice([
      ascii_char([@newline]),
      ascii_char([@carriage_return])
      |> optional(ascii_char([@newline]))
    ])
    |> token(:whitespace)

  comment =
    string("//")
    |> repeat_while(any_unicode, {:not_line_terminator, []})
    |> token(:comment_single)

  comma = ascii_char([?,]) |> token(:punctuation)

  punctuator =
    ascii_char([
      ?(,
      ?),
      ?:,
      ?=,
      ?@,
      ?[,
      ?],
      ?{,
      ?|,
      ?}
    ])
    |> token(:punctuation)

  boolean_value_or_name_or_reserved_word =
    ascii_char([?_, ?A..?Z, ?a..?z])
    |> repeat(ascii_char([?_, ?0..?9, ?A..?Z, ?a..?z]))
    |> optional(ascii_char([??]))
    |> post_traverse({:boolean_value_or_name_or_reserved_word, []})

  negative_sign = ascii_char([?-])

  digit = ascii_char([?0..?9])

  non_zero_digit = ascii_char([?1..?9])

  integer_part =
    optional(negative_sign)
    |> choice([
      ascii_char([?0]),
      non_zero_digit |> repeat(digit)
    ])

  int_value =
    empty()
    |> concat(integer_part)
    |> token(:number_integer)

  fractional_part =
    ascii_char([?.])
    |> times(digit, min: 1)

  float_value =
    choice([
      integer_part |> concat(fractional_part),
      integer_part |> post_traverse({:fill_mantissa, []}),
      integer_part |> concat(fractional_part)
    ])
    |> token(:number_float)

  unicode_char_in_string =
    string("\\u")
    |> ascii_string([?0..?9, ?a..?f, ?A..?F], 4)
    |> token(:string_escape)

  escaped_char =
    string("\\")
    |> utf8_string([], 1)
    |> token(:string_escape)

  combinators_inside_string = [
    unicode_char_in_string,
    escaped_char
  ]

  string_value = string_like("\"", "\"", combinators_inside_string, :string)

  block_string_value = string_like(~S["""], ~S["""], combinators_inside_string, :string)

  root_element_combinator =
    choice([
      unicode_bom,
      whitespace,
      line_terminator,
      comment,
      comma,
      punctuator,
      block_string_value,
      string_value,
      float_value,
      int_value,
      boolean_value_or_name_or_reserved_word
    ])

  @doc false
  def __as_prisma_language__({ttype, meta, value}) do
    {ttype, Map.put(meta, :language, :prisma), value}
  end

  defparsec(
    :root_element,
    root_element_combinator |> map({__MODULE__, :__as_prisma_language__, []})
  )

  defparsec(
    :root,
    repeat(parsec(:root_element))
  )

  defp fill_mantissa(_rest, raw, context, _, _), do: {~c"0." ++ raw, context}

  @boolean_words ~w(
      true
      false
    ) |> Enum.map(&String.to_charlist/1)

  @reserved_words ~w(
      enum
      model
      datasource
      generator
    ) |> Enum.map(&String.to_charlist/1)

  defp boolean_value_or_name_or_reserved_word(rest, chars, context, loc, byte_offset) do
    value = chars |> Enum.reverse()
    do_boolean_value_or_name_or_reserved_word(rest, value, context, loc, byte_offset)
  end

  defp do_boolean_value_or_name_or_reserved_word(_rest, value, context, _loc, _byte_offset)
       when value in @boolean_words do
    {[{:name_constant, %{}, value}], context}
  end

  defp do_boolean_value_or_name_or_reserved_word(_rest, value, context, _loc, _byte_offset)
       when value in @reserved_words do
    {[{:keyword_reserved, %{}, value}], context}
  end

  defp do_boolean_value_or_name_or_reserved_word(_rest, value, context, _loc, _byte_offset) do
    {[{:name, %{}, value}], context}
  end

  def line_and_column({line, line_offset}, byte_offset, column_correction) do
    column = byte_offset - line_offset - column_correction + 1
    {line, column}
  end

  defp not_line_terminator(<<?\n, _::binary>>, context, _, _), do: {:halt, context}
  defp not_line_terminator(<<?\r, _::binary>>, context, _, _), do: {:halt, context}
  defp not_line_terminator(_, context, _, _), do: {:cont, context}
end

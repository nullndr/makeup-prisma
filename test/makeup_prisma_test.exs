defmodule MakeupPrismaTest do
  use ExUnit.Case
  alias Makeup.Lexer.Postprocess
  alias Makeup.Lexers.MakeupPrisma
  doctest MakeupPrisma

  defp lex(text) do
    text
    |> MakeupPrisma.lex(group_prefix: "group")
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end

  test "session from Shopify" do
    schema = """
    model Session {
      id            String    @id
      shop          String
      state         String
      isOnline      Boolean   @default(false)
      scope         String?
      expires       DateTime?
      accessToken   String
      userId        BigInt?
      firstName     String?
      lastName      String?
      email         String?
      accountOwner  Boolean   @default(false)
      locale        String?
      collaborator  Boolean?  @default(false)
      emailVerified Boolean?  @default(false)
    }
    """

    assert lex(schema) == [
             {:keyword_reserved, %{}, "model"},
             {:whitespace, %{}, " "},
             {:name, %{}, "Session"},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "{"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "id"},
             {:whitespace, %{}, "            "},
             {:name, %{}, "String"},
             {:whitespace, %{}, "    "},
             {:punctuation, %{}, "@"},
             {:name, %{}, "id"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "shop"},
             {:whitespace, %{}, "          "},
             {:name, %{}, "String"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "state"},
             {:whitespace, %{}, "         "},
             {:name, %{}, "String"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "isOnline"},
             {:whitespace, %{}, "      "},
             {:name, %{}, "Boolean"},
             {:whitespace, %{}, "   "},
             {:punctuation, %{}, "@"},
             {:name, %{}, "default"},
             {:punctuation, %{}, "("},
             {:name_constant, %{}, "false"},
             {:punctuation, %{}, ")"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "scope"},
             {:whitespace, %{}, "         "},
             {:name, %{}, "String?"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "expires"},
             {:whitespace, %{}, "       "},
             {:name, %{}, "DateTime?"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "accessToken"},
             {:whitespace, %{}, "   "},
             {:name, %{}, "String"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "userId"},
             {:whitespace, %{}, "        "},
             {:name, %{}, "BigInt?"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "firstName"},
             {:whitespace, %{}, "     "},
             {:name, %{}, "String?"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "lastName"},
             {:whitespace, %{}, "      "},
             {:name, %{}, "String?"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "email"},
             {:whitespace, %{}, "         "},
             {:name, %{}, "String?"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "accountOwner"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "Boolean"},
             {:whitespace, %{}, "   "},
             {:punctuation, %{}, "@"},
             {:name, %{}, "default"},
             {:punctuation, %{}, "("},
             {:name_constant, %{}, "false"},
             {:punctuation, %{}, ")"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "locale"},
             {:whitespace, %{}, "        "},
             {:name, %{}, "String?"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "collaborator"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "Boolean?"},
             {:whitespace, %{}, "  "},
             {:punctuation, %{}, "@"},
             {:name, %{}, "default"},
             {:punctuation, %{}, "("},
             {:name_constant, %{}, "false"},
             {:punctuation, %{}, ")"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "emailVerified"},
             {:whitespace, %{}, " "},
             {:name, %{}, "Boolean?"},
             {:whitespace, %{}, "  "},
             {:punctuation, %{}, "@"},
             {:name, %{}, "default"},
             {:punctuation, %{}, "("},
             {:name_constant, %{}, "false"},
             {:punctuation, %{}, ")"},
             {:whitespace, %{}, "\n"},
             {:punctuation, %{}, "}"},
             {:whitespace, %{}, "\n"}
           ]
  end

  test "generators and datasource" do
    schema = """
    generator client {
      provider        = "prisma-client-js"
      previewFeatures = ["fullTextSearch", "omitApi"]
    }

    generator json {
      provider = "prisma-json-types-generator"
    }

    datasource db {
      provider = "postgresql"
      url      = env("DATABASE_URL")
    }
    """

    assert lex(schema) == [
             {:keyword_reserved, %{}, "generator"},
             {:whitespace, %{}, " "},
             {:name, %{}, "client"},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "{"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "provider"},
             {:whitespace, %{}, "        "},
             {:punctuation, %{}, "="},
             {:whitespace, %{}, " "},
             {:string, %{}, "\"prisma-client-js\""},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "previewFeatures"},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "="},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "["},
             {:string, %{}, "\"fullTextSearch\""},
             {:punctuation, %{}, ","},
             {:whitespace, %{}, " "},
             {:string, %{}, "\"omitApi\""},
             {:punctuation, %{}, "]"},
             {:whitespace, %{}, "\n"},
             {:punctuation, %{}, "}"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "\n"},
             {:keyword_reserved, %{}, "generator"},
             {:whitespace, %{}, " "},
             {:name, %{}, "json"},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "{"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "provider"},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "="},
             {:whitespace, %{}, " "},
             {:string, %{}, "\"prisma-json-types-generator\""},
             {:whitespace, %{}, "\n"},
             {:punctuation, %{}, "}"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "\n"},
             {:keyword_reserved, %{}, "datasource"},
             {:whitespace, %{}, " "},
             {:name, %{}, "db"},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "{"},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "provider"},
             {:whitespace, %{}, " "},
             {:punctuation, %{}, "="},
             {:whitespace, %{}, " "},
             {:string, %{}, "\"postgresql\""},
             {:whitespace, %{}, "\n"},
             {:whitespace, %{}, "  "},
             {:name, %{}, "url"},
             {:whitespace, %{}, "      "},
             {:punctuation, %{}, "="},
             {:whitespace, %{}, " "},
             {:name, %{}, "env"},
             {:punctuation, %{}, "("},
             {:string, %{}, "\"DATABASE_URL\""},
             {:punctuation, %{}, ")"},
             {:whitespace, %{}, "\n"},
             {:punctuation, %{}, "}"},
             {:whitespace, %{}, "\n"}
           ]
  end
end

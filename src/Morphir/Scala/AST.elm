module Morphir.Scala.AST exposing (..)


type alias Name =
    String


type alias Path =
    List Name


type alias Documented a =
    { doc : Maybe String
    , value : a
    }


type alias CompilationUnit =
    { dirPath : List String
    , fileName : String
    , packageDecl : PackageDecl
    , imports : List ImportDecl
    , typeDecls : List (Documented TypeDecl)
    }


type alias PackageDecl =
    List String


type alias ImportDecl =
    { isAbsolute : Bool
    , packagePrefix : List String
    , importNames : List ImportName
    }


type ImportName
    = ImportName String
    | ImportRename String String


type Mod
    = Sealed
    | Final
    | Case
    | Val
    | Package
    | Implicit
    | Private (Maybe String)


type TypeDecl
    = Trait
        { modifiers : List Mod
        , name : Name
        , typeArgs : List Type
        , extends : List Type
        , members : List MemberDecl
        }
    | Class
        { modifiers : List Mod
        , name : Name
        , typeArgs : List Type
        , ctorArgs : List (List ArgDecl)
        , extends : List Type
        }
    | Object
        { modifiers : List Mod
        , name : Name
        , extends : List Type
        , members : List MemberDecl
        }


type alias ArgDecl =
    { modifiers : List Mod
    , tpe : Type
    , name : Name
    , defaultValue : Maybe Value
    }


type ArgValue
    = ArgValue (Maybe Name) Value


type MemberDecl
    = TypeAlias
        { alias : Name
        , typeArgs : List Type
        , tpe : Type
        }
    | FunctionDecl
        { modifiers : List Mod
        , name : Name
        , typeArgs : List Type
        , args : List (List ArgDecl)
        , returnType : Maybe Type
        , body : Maybe Value
        }
    | MemberTypeDecl TypeDecl


type Type
    = TypeVar Name
    | TypeRef Path Name
    | TypeApply Type (List Type)
    | TupleType (List Type)
    | StructuralType (List MemberDecl)
    | FunctionType Type Type
    | CommentedType Type String


type Value
    = Literal Lit
    | Var Name
    | Ref Path Name
    | Select Value Name
    | Wildcard
    | Apply Value (List ArgValue)
    | UnOp String Value
    | BinOp Value String Value
    | Lambda (List Name) Value
    | LetBlock (List ( Pattern, Value )) Value
    | MatchCases (List ( Pattern, Value ))
    | Match Value Value
    | IfElse Value Value Value
    | Tuple (List Value)
    | CommentedValue Value String


type Pattern
    = WildcardMatch
    | NamedMatch Name
    | AliasedMatch Name Pattern
    | LiteralMatch Lit
    | UnapplyMatch Path Name (List Pattern)
    | TupleMatch (List Pattern)
    | EmptyListMatch
    | HeadTailMatch Pattern Pattern
    | CommentedPattern Pattern String


type Lit
    = BooleanLit Bool
    | CharacterLit Char
    | StringLit String
    | IntegerLit Int
    | FloatLit Float


nameOfTypeDecl : TypeDecl -> Name
nameOfTypeDecl typeDecl =
    case typeDecl of
        Trait data ->
            data.name

        Class data ->
            data.name

        Object data ->
            data.name

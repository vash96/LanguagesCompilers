-- Haskell data types for the abstract syntax.
-- Generated by the BNF converter.

module AbsChapel where

newtype Ident = Ident String
  deriving (Eq, Ord, Show, Read)

data Program = Prog [Decl]
  deriving (Eq, Ord, Show, Read)

data Decl
    = FDecl Ident [Form] Intent Type Block
    | VList [VDecl]
    | CList [CDecl]
  deriving (Eq, Ord, Show, Read)

data Form = Form Intent Ident Type
  deriving (Eq, Ord, Show, Read)

data Intent = In | Out | InOut | Ref | ConstIn | ConstRef
  deriving (Eq, Ord, Show, Read)

data VDecl = Solo Ident Type | Init Ident Type RExp
  deriving (Eq, Ord, Show, Read)

data CDecl = CDecl Ident Type RExp
  deriving (Eq, Ord, Show, Read)

data Type = Type Compound Basic
  deriving (Eq, Ord, Show, Read)

data Compound = Simple | Array Compound RExp | Pointer Compound
  deriving (Eq, Ord, Show, Read)

data Basic = BBool | BChar | BInt | BReal | BString | BVoid
  deriving (Eq, Ord, Show, Read)

data Block = Block [Decl] [Stm]
  deriving (Eq, Ord, Show, Read)

data Stm
    = StmBlock Block
    | StmCall Ident [RExp]
    | PredW PWrite RExp
    | Assign LExp AssignOp RExp
    | StmL LExp
    | If RExp Stm
    | IfElse RExp Stm Stm
    | While RExp Stm
    | DoWhile Stm RExp
    | For Ident Range Stm
    | JmpStm Jump
  deriving (Eq, Ord, Show, Read)

data Jump = Return | ReturnE RExp | Break | Continue
  deriving (Eq, Ord, Show, Read)

data Range = Range RExp RExp
  deriving (Eq, Ord, Show, Read)

data LExp
    = Deref LExp
    | Post LExp IncDecOp
    | Pre IncDecOp LExp
    | Access LExp RExp
    | Name Ident
  deriving (Eq, Ord, Show, Read)

data RExp
    = Or RExp RExp
    | And RExp RExp
    | Not RExp
    | Comp RExp CompOp RExp
    | Arith RExp ArithOp RExp
    | Sign SignOp RExp
    | RefE LExp
    | RLExp LExp
    | ArrList [RExp]
    | FCall Ident [RExp]
    | PredR PRead
    | Lit Literal
  deriving (Eq, Ord, Show, Read)

data PRead = ReadChar | ReadInt | ReadFloat | ReadString
  deriving (Eq, Ord, Show, Read)

data PWrite = WriteChar | WriteInt | WriteFloat | WriteString
  deriving (Eq, Ord, Show, Read)

data ArithOp = Add | Sub | Mul | Div | Mod | Pow
  deriving (Eq, Ord, Show, Read)

data AssignOp
    = AssignEq
    | AssignAdd
    | AssignSub
    | AssignMul
    | AssignDiv
    | AssignMod
    | AssignPow
  deriving (Eq, Ord, Show, Read)

data CompOp = Lt | Leq | Eq | Neq | Geq | Gt
  deriving (Eq, Ord, Show, Read)

data IncDecOp = Inc | Dec
  deriving (Eq, Ord, Show, Read)

data SignOp = Pos | Neg
  deriving (Eq, Ord, Show, Read)

data Literal
    = LBool Bool
    | LChar Char
    | LInt Integer
    | LReal Double
    | LString String
  deriving (Eq, Ord, Show, Read)
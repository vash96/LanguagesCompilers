-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module ParGarpezpp where
import AbsGarpezpp
import LexGarpezpp
import ErrM

}

%name pProgram Program
-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype {Token}
%token
  '!' { PT _ (TS _ 1) }
  '!=' { PT _ (TS _ 2) }
  '%' { PT _ (TS _ 3) }
  '%=' { PT _ (TS _ 4) }
  '&' { PT _ (TS _ 5) }
  '&&' { PT _ (TS _ 6) }
  '(' { PT _ (TS _ 7) }
  ')' { PT _ (TS _ 8) }
  '*' { PT _ (TS _ 9) }
  '*=' { PT _ (TS _ 10) }
  '+' { PT _ (TS _ 11) }
  '++' { PT _ (TS _ 12) }
  '+=' { PT _ (TS _ 13) }
  ',' { PT _ (TS _ 14) }
  '-' { PT _ (TS _ 15) }
  '--' { PT _ (TS _ 16) }
  '-=' { PT _ (TS _ 17) }
  '/' { PT _ (TS _ 18) }
  '/=' { PT _ (TS _ 19) }
  ';' { PT _ (TS _ 20) }
  '<' { PT _ (TS _ 21) }
  '<=' { PT _ (TS _ 22) }
  '=' { PT _ (TS _ 23) }
  '==' { PT _ (TS _ 24) }
  '>' { PT _ (TS _ 25) }
  '>=' { PT _ (TS _ 26) }
  '[' { PT _ (TS _ 27) }
  ']' { PT _ (TS _ 28) }
  '^' { PT _ (TS _ 29) }
  'bool' { PT _ (TS _ 30) }
  'break' { PT _ (TS _ 31) }
  'char' { PT _ (TS _ 32) }
  'const' { PT _ (TS _ 33) }
  'continue' { PT _ (TS _ 34) }
  'do' { PT _ (TS _ 35) }
  'downto' { PT _ (TS _ 36) }
  'else' { PT _ (TS _ 37) }
  'false' { PT _ (TS _ 38) }
  'float' { PT _ (TS _ 39) }
  'for' { PT _ (TS _ 40) }
  'if' { PT _ (TS _ 41) }
  'int' { PT _ (TS _ 42) }
  'readChar' { PT _ (TS _ 43) }
  'readFloat' { PT _ (TS _ 44) }
  'readInt' { PT _ (TS _ 45) }
  'readString' { PT _ (TS _ 46) }
  'ref' { PT _ (TS _ 47) }
  'return' { PT _ (TS _ 48) }
  'string' { PT _ (TS _ 49) }
  'true' { PT _ (TS _ 50) }
  'upto' { PT _ (TS _ 51) }
  'val' { PT _ (TS _ 52) }
  'void' { PT _ (TS _ 53) }
  'while' { PT _ (TS _ 54) }
  'writeChar' { PT _ (TS _ 55) }
  'writeFloat' { PT _ (TS _ 56) }
  'writeInt' { PT _ (TS _ 57) }
  'writeString' { PT _ (TS _ 58) }
  '{' { PT _ (TS _ 59) }
  '||' { PT _ (TS _ 60) }
  '}' { PT _ (TS _ 61) }
  L_ident  { PT _ (TV $$) }
  L_charac { PT _ (TC $$) }
  L_integ  { PT _ (TI $$) }
  L_doubl  { PT _ (TD $$) }
  L_quoted { PT _ (TL $$) }

%%

Ident   :: { Ident }
Ident    : L_ident  { Ident $1 }

Char    :: { Char }
Char     : L_charac { (read ( $1)) :: Char }

Integer :: { Integer }
Integer  : L_integ  { (read ( $1)) :: Integer }

Double  :: { Double }
Double   : L_doubl  { (read ( $1)) :: Double }

String  :: { String }
String   : L_quoted {  $1 }

Program :: { Program }
Program : ListFDecl { AbsGarpezpp.Prog $1 }
FDecl :: { FDecl }
FDecl : RType Ident '(' ListParam ')' Block { AbsGarpezpp.FDecl $1 $2 $4 $6 }
Param :: { Param }
Param : Type PassBy Ident { AbsGarpezpp.Param $1 $2 $3 }
PassBy :: { PassBy }
PassBy : 'val' { AbsGarpezpp.PassVal }
       | 'ref' { AbsGarpezpp.PassRef }
DList :: { DList }
DList : Type ListVDecl ';' { AbsGarpezpp.VList $1 $2 }
      | 'const' ListCDecl ';' { AbsGarpezpp.CList $2 }
VDecl :: { VDecl }
VDecl : Ident { AbsGarpezpp.VSolo $1 }
      | Ident '=' RExp { AbsGarpezpp.VInit $1 $3 }
CDecl :: { CDecl }
CDecl : Ident '=' RExp { AbsGarpezpp.CDecl $1 $3 }
Type :: { Type }
Type : Basic Compound { AbsGarpezpp.Type $1 $2 }
Compound :: { Compound }
Compound : {- empty -} { AbsGarpezpp.Simple }
         | Compound '[' RExp ']' { AbsGarpezpp.Array $1 $3 }
         | Compound '*' { AbsGarpezpp.Pointer $1 }
Basic :: { Basic }
Basic : 'bool' { AbsGarpezpp.BBool }
      | 'char' { AbsGarpezpp.BChar }
      | 'int' { AbsGarpezpp.BInt }
      | 'float' { AbsGarpezpp.BFloat }
      | 'string' { AbsGarpezpp.BString }
RType :: { RType }
RType : 'void' { AbsGarpezpp.RVoid }
      | Basic { AbsGarpezpp.RBasic $1 }
      | Type '&' { AbsGarpezpp.RRef $1 }
Block :: { Block }
Block : '{' ListDList ListStm '}' { AbsGarpezpp.Block (reverse $2) (reverse $3) }
Stm :: { Stm }
Stm : Block { AbsGarpezpp.StmBlock $1 }
    | Ident '(' ListRExp ')' ';' { AbsGarpezpp.StmCall $1 $3 }
    | PWrite '(' RExp ')' ';' { AbsGarpezpp.PredW $1 $3 }
    | LExp AssignOp RExp ';' { AbsGarpezpp.Assign $1 $2 $3 }
    | LExp ';' { AbsGarpezpp.StmL $1 }
    | 'if' '(' RExp ')' Stm { AbsGarpezpp.If $3 $5 }
    | 'if' '(' RExp ')' Stm 'else' Stm { AbsGarpezpp.IfElse $3 $5 $7 }
    | 'while' '(' RExp ')' Stm { AbsGarpezpp.While $3 $5 }
    | 'do' Stm 'while' '(' RExp ')' ';' { AbsGarpezpp.DoWhile $2 $5 }
    | 'for' '(' Ident '=' RExp Dir RExp ')' Stm { AbsGarpezpp.For $3 $5 $6 $7 $9 }
    | Jump ';' { AbsGarpezpp.JmpStm $1 }
Dir :: { Dir }
Dir : 'upto' { AbsGarpezpp.UpTo } | 'downto' { AbsGarpezpp.DownTo }
Jump :: { Jump }
Jump : 'return' { AbsGarpezpp.Return }
     | 'return' RExp { AbsGarpezpp.ReturnE $2 }
     | 'break' { AbsGarpezpp.Break }
     | 'continue' { AbsGarpezpp.Continue }
LExp :: { LExp }
LExp : LExp1 { $1 } | '*' LExp { AbsGarpezpp.Deref $2 }
LExp1 :: { LExp }
LExp1 : LExp2 { $1 } | LExp2 IncDecOp { AbsGarpezpp.Post $1 $2 }
LExp2 :: { LExp }
LExp2 : LExp3 { $1 } | IncDecOp LExp3 { AbsGarpezpp.Pre $1 $2 }
LExp3 :: { LExp }
LExp3 : LExp4 { $1 }
      | LExp3 '[' RExp ']' { AbsGarpezpp.Access $1 $3 }
LExp4 :: { LExp }
LExp4 : '(' LExp ')' { $2 } | Ident { AbsGarpezpp.Name $1 }
RExp :: { RExp }
RExp : RExp1 { $1 } | RExp '||' RExp1 { AbsGarpezpp.Or $1 $3 }
RExp1 :: { RExp }
RExp1 : RExp2 { $1 } | RExp1 '&&' RExp2 { AbsGarpezpp.And $1 $3 }
RExp2 :: { RExp }
RExp2 : RExp3 { $1 } | '!' RExp3 { AbsGarpezpp.Not $2 }
RExp3 :: { RExp }
RExp3 : RExp4 { $1 }
      | RExp3 CompOp RExp4 { AbsGarpezpp.Comp $1 $2 $3 }
RExp4 :: { RExp }
RExp4 : RExp5 { $1 }
      | RExp4 '+' RExp5 { AbsGarpezpp.Add $1 $3 }
      | RExp4 '-' RExp5 { AbsGarpezpp.Sub $1 $3 }
RExp5 :: { RExp }
RExp5 : RExp6 { $1 }
      | RExp5 '*' RExp6 { AbsGarpezpp.Mul $1 $3 }
      | RExp5 '/' RExp6 { AbsGarpezpp.Div $1 $3 }
      | RExp5 '%' RExp6 { AbsGarpezpp.Rem $1 $3 }
RExp6 :: { RExp }
RExp6 : RExp7 { $1 } | RExp7 '^' RExp6 { AbsGarpezpp.Pow $1 $3 }
RExp7 :: { RExp }
RExp7 : RExp8 { $1 }
      | SignOp RExp8 { AbsGarpezpp.Sign $1 $2 }
      | '&' LExp { AbsGarpezpp.Ref $2 }
RExp8 :: { RExp }
RExp8 : RExp9 { $1 } | LExp { AbsGarpezpp.RLExp $1 }
RExp9 :: { RExp }
RExp9 : RExp10 { $1 }
      | '[' ListRExp ']' { AbsGarpezpp.ArrList $2 }
      | Ident '(' ListRExp ')' { AbsGarpezpp.FCall $1 $3 }
      | PRead '(' ')' { AbsGarpezpp.PredR $1 }
RExp10 :: { RExp }
RExp10 : '(' RExp ')' { $2 } | Literal { AbsGarpezpp.Lit $1 }
PRead :: { PRead }
PRead : 'readChar' { AbsGarpezpp.ReadChar }
      | 'readInt' { AbsGarpezpp.ReadInt }
      | 'readFloat' { AbsGarpezpp.ReadFloat }
      | 'readString' { AbsGarpezpp.ReadString }
PWrite :: { PWrite }
PWrite : 'writeChar' { AbsGarpezpp.WriteChar }
       | 'writeInt' { AbsGarpezpp.WriteInt }
       | 'writeFloat' { AbsGarpezpp.WriteFloat }
       | 'writeString' { AbsGarpezpp.WriteString }
AssignOp :: { AssignOp }
AssignOp : '=' { AbsGarpezpp.AssignEq }
         | '+=' { AbsGarpezpp.AssignAdd }
         | '-=' { AbsGarpezpp.AssignSub }
         | '*=' { AbsGarpezpp.AssignMul }
         | '/=' { AbsGarpezpp.AssignDiv }
         | '%=' { AbsGarpezpp.AssignMod }
CompOp :: { CompOp }
CompOp : '<' { AbsGarpezpp.Lt }
       | '<=' { AbsGarpezpp.Leq }
       | '==' { AbsGarpezpp.Eq }
       | '!=' { AbsGarpezpp.Neq }
       | '>=' { AbsGarpezpp.Geq }
       | '>' { AbsGarpezpp.Gt }
IncDecOp :: { IncDecOp }
IncDecOp : '++' { AbsGarpezpp.Inc } | '--' { AbsGarpezpp.Dec }
SignOp :: { SignOp }
SignOp : '+' { AbsGarpezpp.Pos } | '-' { AbsGarpezpp.Neg }
Literal :: { Literal }
Literal : Boolean { AbsGarpezpp.LBool $1 }
        | Char { AbsGarpezpp.LChar $1 }
        | Integer { AbsGarpezpp.LInt $1 }
        | Double { AbsGarpezpp.LFloat $1 }
        | String { AbsGarpezpp.LString $1 }
Boolean :: { Boolean }
Boolean : 'false' { AbsGarpezpp.BFalse }
        | 'true' { AbsGarpezpp.BTrue }
ListParam :: { [Param] }
ListParam : {- empty -} { [] }
          | Param { (:[]) $1 }
          | Param ',' ListParam { (:) $1 $3 }
ListFDecl :: { [FDecl] }
ListFDecl : FDecl { (:[]) $1 } | FDecl ListFDecl { (:) $1 $2 }
ListVDecl :: { [VDecl] }
ListVDecl : VDecl { (:[]) $1 } | VDecl ',' ListVDecl { (:) $1 $3 }
ListCDecl :: { [CDecl] }
ListCDecl : CDecl { (:[]) $1 } | CDecl ',' ListCDecl { (:) $1 $3 }
ListDList :: { [DList] }
ListDList : {- empty -} { [] } | ListDList DList { flip (:) $1 $2 }
ListStm :: { [Stm] }
ListStm : {- empty -} { [] } | ListStm Stm { flip (:) $1 $2 }
ListRExp :: { [RExp] }
ListRExp : RExp { (:[]) $1 } | RExp ',' ListRExp { (:) $1 $3 }
{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++
  case ts of
    []      -> []
    [Err _] -> " due to lexer error"
    t:_     -> " before `" ++ id(prToken t) ++ "'"

myLexer = tokens
}


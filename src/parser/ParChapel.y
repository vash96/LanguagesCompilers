-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module ParChapel where
import AbsChapel
import LexChapel
import ErrM
import Locatable

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
  '..' { PT _ (TS _ 18) }
  '/' { PT _ (TS _ 19) }
  '/=' { PT _ (TS _ 20) }
  ':' { PT _ (TS _ 21) }
  ';' { PT _ (TS _ 22) }
  '<' { PT _ (TS _ 23) }
  '<=' { PT _ (TS _ 24) }
  '=' { PT _ (TS _ 25) }
  '==' { PT _ (TS _ 26) }
  '>' { PT _ (TS _ 27) }
  '>=' { PT _ (TS _ 28) }
  '[' { PT _ (TS _ 29) }
  ']' { PT _ (TS _ 30) }
  '^' { PT _ (TS _ 31) }
  '^=' { PT _ (TS _ 32) }
  'bool' { PT _ (TS _ 33) }
  'break' { PT _ (TS _ 34) }
  'char' { PT _ (TS _ 35) }
  'const' { PT _ (TS _ 36) }
  'continue' { PT _ (TS _ 37) }
  'do' { PT _ (TS _ 38) }
  'else' { PT _ (TS _ 39) }
  'false' { PT _ (TS _ 40) }
  'for' { PT _ (TS _ 41) }
  'if' { PT _ (TS _ 42) }
  'in' { PT _ (TS _ 43) }
  'inout' { PT _ (TS _ 44) }
  'int' { PT _ (TS _ 45) }
  'out' { PT _ (TS _ 46) }
  'param' { PT _ (TS _ 47) }
  'proc' { PT _ (TS _ 48) }
  'real' { PT _ (TS _ 49) }
  'ref' { PT _ (TS _ 50) }
  'return' { PT _ (TS _ 51) }
  'string' { PT _ (TS _ 52) }
  'then' { PT _ (TS _ 53) }
  'true' { PT _ (TS _ 54) }
  'var' { PT _ (TS _ 55) }
  'void' { PT _ (TS _ 56) }
  'while' { PT _ (TS _ 57) }
  '{' { PT _ (TS _ 58) }
  '||' { PT _ (TS _ 59) }
  '}' { PT _ (TS _ 60) }
  L_ident  { PT _ (TV _) }
  L_charac { PT _ (TC _) }
  L_integ  { PT _ (TI _) }
  L_doubl  { PT _ (TD _) }
  L_quoted { PT _ (TL _) }

  %left ';'
  %left '||'
  %left '&&'
  %nonassoc '==' '!='
  %nonassoc '<' '<=' '>=' '>'
  %left '+' '-'
  %left '*' '/' '%'
  %right '!' SIGN
  %right '^'
  %nonassoc '++' '--'
  %nonassoc PREINCDEC
  %left '[' ']'
  %left '(' ')'

%%

Ident   :: { Ident }
Ident    : L_ident  { Ident (tokenLoc $1) (tokenValue $1) }

Char    :: { (Loc, Char) }
Char     : L_charac { (tokenLoc $1, ((read . tokenValue) $1) :: Char) }

Integer :: { (Loc, Integer) }
Integer  : L_integ  { (tokenLoc $1, ((read . tokenValue) $1) :: Integer) }

Double  :: { (Loc, Double) }
Double   : L_doubl  { (tokenLoc $1, ((read . tokenValue) $1) :: Double) }

String  :: { (Loc, String) }
String   : L_quoted { (tokenLoc $1, tokenValue $1) }

Program :: { Program () }
Program : ListDecl { AbsChapel.Prog $1 }

Decl :: { Decl () }
Decl : 'proc' Ident '(' ListForm ')' Intent ':' Type Block { AbsChapel.FDecl $2 $4 $6 $8 $9 }
     | 'var' ListVDecl ';' { AbsChapel.VList $2 }
     | 'param' ListCDecl ';' { AbsChapel.CList $2 }

Form :: { Form () }
Form : Intent Ident ':' Type { AbsChapel.Form $1 $2 $4 }

Intent :: { Intent }
Intent : {- empty -} { AbsChapel.In }
       | 'in' { AbsChapel.In }
       | 'out' { AbsChapel.Out }
       | 'inout' { AbsChapel.InOut }
       | 'ref' { AbsChapel.Ref }
       | 'const' 'in' { AbsChapel.ConstIn }
       | 'const' 'ref' { AbsChapel.ConstRef }

VDecl :: { VDecl () }
VDecl : Ident ':' Type { AbsChapel.Solo $1 $3 }
      | Ident ':' Type '=' RExp { AbsChapel.Init $1 $3 $5 }

CDecl :: { CDecl () }
CDecl : Ident ':' Type '=' RExp { AbsChapel.CDecl $1 $3 $5 }

Type :: { Type () }
Type : Compound Basic { AbsChapel.Type $1 $2 }

Compound :: { Compound () }
Compound : {- empty -} { AbsChapel.Simple }
         | Compound '[' RExp ']' { AbsChapel.Array $1 $3 }
         | Compound '*' { AbsChapel.Pointer $1 }

Basic :: { Basic }
Basic : 'bool' { AbsChapel.BBool }
      | 'char' { AbsChapel.BChar }
      | 'int' { AbsChapel.BInt }
      | 'real' { AbsChapel.BReal }
      | 'string' { AbsChapel.BString }
      | 'void' { AbsChapel.BVoid }

Block :: { Block () }
Block : '{' {- empty -} '}' { AbsChapel.Block (tokenLoc $1) [] [] }
      | '{' ListDecl '}' { AbsChapel.Block (tokenLoc $1) $2 [] }
      | '{' ListStm '}' { AbsChapel.Block (tokenLoc $1) [] $2 }
      | '{' ListDecl ListStm '}' { AbsChapel.Block (tokenLoc $1) $2 $3 }

Stm :: { Stm () }
Stm : ';' Stm { $2 }
    | Block { AbsChapel.StmBlock $1 }
    | Ident '(' ListRExp ')' ';' { AbsChapel.StmCall $1 $3 }
    
    | LExp '='  RExp ';' { AbsChapel.Assign $1 (AbsChapel.AssignEq  (tokenLoc $2) ()) $3 }
    | LExp '+=' RExp ';' { AbsChapel.Assign $1 (AbsChapel.AssignAdd (tokenLoc $2) ()) $3 }
    | LExp '-=' RExp ';' { AbsChapel.Assign $1 (AbsChapel.AssignSub (tokenLoc $2) ()) $3 }
    | LExp '*=' RExp ';' { AbsChapel.Assign $1 (AbsChapel.AssignMul (tokenLoc $2) ()) $3 }
    | LExp '/=' RExp ';' { AbsChapel.Assign $1 (AbsChapel.AssignDiv (tokenLoc $2) ()) $3 }
    | LExp '%=' RExp ';' { AbsChapel.Assign $1 (AbsChapel.AssignMod (tokenLoc $2)) $3 }
    | LExp '^=' RExp ';' { AbsChapel.Assign $1 (AbsChapel.AssignPow (tokenLoc $2) ()) $3 }

    | LExp ';' { AbsChapel.StmL $1 }

    | 'if' RExp 'then' Stm { AbsChapel.If $2 $4 }
    | 'if' RExp Block { AbsChapel.If $2 (AbsChapel.StmBlock $3) }
    | 'if' RExp 'then' Stm 'else' Stm { AbsChapel.IfElse $2 $4 $6 }
    | 'if' RExp Block 'else' Stm { AbsChapel.IfElse $2 (AbsChapel.StmBlock $3) $5 }

    | 'while' RExp 'do' Stm { AbsChapel.While $2 $4 }
    | 'while' RExp Block { AbsChapel.While $2 (AbsChapel.StmBlock $3) }
    | 'do' Stm 'while' RExp ';' { AbsChapel.DoWhile $2 $4 }
    | 'for' Ident 'in' Range 'do' Stm { AbsChapel.For $2 $4 $6 }
    | 'for' Ident 'in' Range Block { AbsChapel.For $2 $4 (AbsChapel.StmBlock $5) }
    | 'return' ';' { AbsChapel.JmpStm (AbsChapel.Return (tokenLoc $1)) }
    | 'return' RExp ';' { AbsChapel.JmpStm (AbsChapel.ReturnE (tokenLoc $1) $2 ()) }
    | 'break' ';' { AbsChapel.JmpStm (AbsChapel.Break (tokenLoc $1)) }
    | 'continue' ';' { AbsChapel.JmpStm (AbsChapel.Continue (tokenLoc $1)) }

Range :: { Range () }
Range : '{' RExp '..' RExp '}' { AbsChapel.Range (tokenLoc $3) $2 $4 }

LExp :: { LExp () }
LExp : '*' LExp { AbsChapel.Deref $2 () }
--     | LExp IncDecOp { AbsChapel.Post $1 $2 }
--     | IncDecOp LExp { AbsChapel.Pre $1 $2 }
     | LExp '[' RExp ']' { AbsChapel.Access $1 $3 () }
     | Ident { AbsChapel.Name $1 () }

     | '(' LExp ')' { $2 }

RExp :: { RExp () }
RExp : RExp '||' RExp { AbsChapel.Or (tokenLoc $2) $1 $3 () }
     | RExp '&&' RExp { AbsChapel.And (tokenLoc $2) $1 $3 () }
     | '!' RExp { AbsChapel.Not (tokenLoc $1) $2 () }

     | RExp '<' RExp { AbsChapel.Comp (tokenLoc $2) $1 (AbsChapel.Lt ()) $3 () }
     | RExp '<=' RExp { AbsChapel.Comp (tokenLoc $2) $1 (AbsChapel.Leq ()) $3 () }
     | RExp '==' RExp { AbsChapel.Comp (tokenLoc $2) $1 (AbsChapel.Eq ()) $3 () }
     | RExp '!=' RExp { AbsChapel.Comp (tokenLoc $2) $1 (AbsChapel.Neq ()) $3 () }
     | RExp '>=' RExp { AbsChapel.Comp (tokenLoc $2) $1 (AbsChapel.Geq ()) $3 () }
     | RExp '>' RExp { AbsChapel.Comp (tokenLoc $2) $1 (AbsChapel.Gt ()) $3 () }

     | RExp '+' RExp { AbsChapel.Arith (tokenLoc $2) $1 (AbsChapel.Add ()) $3 () }
     | RExp '-' RExp { AbsChapel.Arith (tokenLoc $2) $1 (AbsChapel.Sub ()) $3 () }
     | RExp '*' RExp { AbsChapel.Arith (tokenLoc $2) $1 (AbsChapel.Mul ()) $3 () }
     | RExp '/' RExp { AbsChapel.Arith (tokenLoc $2) $1 (AbsChapel.Div ()) $3 () }
     | RExp '%' RExp { AbsChapel.Arith (tokenLoc $2) $1 AbsChapel.Mod $3 () }
     | RExp '^' RExp { AbsChapel.Arith (tokenLoc $2) $1 (AbsChapel.Pow ()) $3 () }
     
     | '+' RExp %prec SIGN { AbsChapel.Sign (tokenLoc $1) (AbsChapel.Pos ()) $2 () }
     | '-' RExp %prec SIGN { AbsChapel.Sign (tokenLoc $1) (AbsChapel.Neg ()) $2 () }

     | '&' LExp { AbsChapel.RefE (tokenLoc $1) $2 () }
     | LExp { AbsChapel.RLExp (locOf $1) $1 () }
     | '[' ListRExp ']' { AbsChapel.ArrList (tokenLoc $1) $2 () }
     | Ident '(' ListRExp ')' { AbsChapel.FCall (locOf $1) $1 $3 () }
     | Literal { AbsChapel.Lit (fst $1) (snd $1) () }

     | '(' RExp ')' { $2 }

-- IncDecOp :: { IncDecOp }
-- IncDecOp : '++' { AbsChapel.Inc } | '--' { AbsChapel.Dec }

Literal :: { (Loc, Literal) }
Literal : 'false' { (tokenLoc $1, AbsChapel.LBool False) }
        | 'true' { (tokenLoc $1, AbsChapel.LBool True) }
        | Char { (fst $1, AbsChapel.LChar (snd $1)) }
        | Integer { (fst $1, AbsChapel.LInt (snd $1)) }
        | Double { (fst $1, AbsChapel.LReal (snd $1)) }
        | String { (fst $1, AbsChapel.LString (snd $1)) }

ListForm :: { [Form ()] }
ListForm : {- empty -} { [] }
         | Form { (:[]) $1 }
         | Form ',' ListForm { (:) $1 $3 }

ListDecl :: { [Decl ()] }
ListDecl : Decl { (:[]) $1 }
         | Decl ListDecl { (:) $1 $2 }

ListVDecl :: { [VDecl ()] }
ListVDecl : VDecl { (:[]) $1 } | VDecl ',' ListVDecl { (:) $1 $3 }

ListCDecl :: { [CDecl ()] }
ListCDecl : CDecl { (:[]) $1 } | CDecl ',' ListCDecl { (:) $1 $3 }

ListStm :: { [Stm ()] }
ListStm : Stm { (:[]) $1 }
        | Stm ListStm { (:) $1 $2 }

ListRExp :: { [RExp ()] }
ListRExp : {- empty -} { [] }
         | RExp { (:[]) $1 }
         | RExp ',' ListRExp { (:) $1 $3 }
{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

tokenLoc :: Token -> Loc
tokenLoc tk = let (l, c) = tokenLineCol tk in (Loc l c)

tokenTok :: Token -> Tok
tokenTok (PT _ t) = t

tokenValue :: Token -> String
tokenValue = strOf . tokenTok

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++
  case ts of
    []      -> []
    [Err _] -> " due to lexer error"
    t:_     -> " before `" ++ id(prToken t) ++ "'"

myLexer = tokens
}
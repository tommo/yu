--[[
	known issue:
		nested parenthesis is limited by lpeg, will look for some workaround
]]

if not rawget(_G,'lpeg')then
	require "lpeg"
end
require "yu.type"

local ipairs,pairs=ipairs,pairs
local io,type=io,type
local print,error,assert=print,error,assert
local setmetatable=setmetatable
local L=lpeg

module ("yu" ,package.seeall)
setmetatable(_M,{__index=function(t,k) error("undefined symbol:"..k,2) end}) --strict mode

local p,s,r,b,lpegv =L.P,L.S,L.R,L.B,L.V
local c,carg,cb,cc,cp,cs,ct,cg,cmt,cf= L.C,L.Carg,L.Cb,L.Cc,L.Cp,L.Cs,L.Ct,L.Cg,L.Cmt,L.Cf

local v=setmetatable({},{__index=function(t,k) return lpegv(k) end})

---CONTEXT
local currentParsedSource=false
local currentLine=1
local currentLineOffset=0
local currentOffsetTable={0}
local lineOffset={}
local currentFilePath=''
local errors = {}
local function newline(off) 
	currentLine=currentLine+1
	currentLineOffset=off
	lineOffset[currentLine]=off
	currentOffsetTable[currentLine]=off
end

local function resetContext()
	currentLine=1
	currentLineOffset=0
	currentOffsetTable={0}
	lineOffset={}
	errors={}
end

local function checkConst(t)
	local tag=t and t.tag
	return tag and tag=='number' or tag=='boolean' or tag=='string' or tag=='nil'
end

local function parseErr(msg,pos)
	local lpos=pos-currentLineOffset
	local m=currentFilePath.."<"..currentLine..":"..lpos..">:"..msg
	errors[#errors+1]=m
end
	--cmt(p(1),f

local function getModuleMatch()

	--HELPER FUNCTIONS
	local function ccheck(patt,checker,msg)
		local function checkerfunc(pos,c)
			if checker(c) then
				return c
			else
				return parseErr(msg,pos)
			end
		end

		return (cp()*patt)/checkerfunc

	end

	local function cnot(patt,f) return cg(cp(),'p0')*(patt+(cb'p0'*cp()/f)) end

	local function cassert(patt,msg) return cnot(patt,function(s0,s1) 
		return parseErr(msg,s1) 
	end) end

	local function c1 (s, o) return s end

	local function t0(tag)	return function() return {tag=tag} end end

	local function t1(tag,a)
		return function(v) return {tag=tag,[a]=v} end
	end

	local function t2(tag,k1,k2)
		--assert(k1 and k2)
		return function(v1,v2) return {tag=tag,[k1]=v1,[k2]=v2} end
	end

	local function t3(tag,k1,k2,k3)
		assert(k1 and k2 and k3)
		return function(v1,v2,v3) return {tag=tag,[k1]=v1,[k2]=v2,[k3]=v3} end
	end

	local function t4(tag,k1,k2,k3,k4)
		assert(k1 and k2 and k3 and k4)
		return function(v1,v2,v3,v4) return {tag=tag,[k1]=v1,[k2]=v2,[k3]=v3,[k4]=v4} end
	end

	local function t5(tag,k1,k2,k3,k4,k5)
		assert(k1 and k2 and k3 and k4 and k5)
		return function(v1,v2,v3,v4,v5) return {tag=tag,[k1]=v1,[k2]=v2,[k3]=v3,[k4]=v4,[k5]=v5} end
	end

	local function t6(tag,k1,k2,k3,k4,k5,k6)
		assert(k1 and k2 and k3 and k4 and k5 and k6)
		return function(v1,v2,v3,v4,v5,v6) return {tag=tag,[k1]=v1,[k2]=v2,[k3]=v3,[k4]=v4,[k5]=v5,[k6]=v6} end
	end

	local function tt(tag,t)
		return function(...)  return {tag=tag,[t]={...}} end
	end

	local function tc(tag,c)
		c.tag=tag
		return function() return c end
	end

	local function cpos(patt)
		return (cp()*patt*cp()/function(p0,t,p1)
			if type(t)~="table" then return nil end
			t.p0=t.p0 or p0
			t.p1=t.p1 or p1
			return t
		end)
	end

	 --------------TERMINAL

	local DIGIT=r'09'
	local _=s' \t'^0

	local ALPHA=r'AZ'+r'az'+'_'
	local ALPHADIGIT=ALPHA+DIGIT
	local Name=ALPHA*ALPHADIGIT^0


	local EOL= (p'\n'+p'\r\n'+p'\r')*cp()/newline


	local LESSEQ=p'<='
	local NOTEQ=p'~='
	local LESS=p'<'
	local GREATEQ=p'>='
	local GREATER=p'>'
	local EQ=p'=='
	local NOTEQ1=p'<>'

	local ASSIGN=p'='
	local ASSDEF=p':='
	local ASSCAST=p'=:'

	local ASSADD=p'+='
	local ASSSUB=p'-='
	local ASSMUL=p'*='
	local ASSDIV=p'/='
	local ASSPOW=p'^='
	local ASSMOD=p'%='
	local ASSCON=p'..='
	local ASSAND=p'or='
	local ASSOR=p'and='

	local ARROWE=p'=>'
	local ARROW=p'->'
	local STICK=p'|'

	local POPEN,PCLOSE=p'(',p')'
	local BOPEN,BCLOSE=p'{',p'}'
	local SOPEN,SCLOSE=p'[',p']'

	local SLASH=p'/'
	local STAR=p'*'
	local MINUS=p'-'
	local PLUS=p'+'
	local POW=p'^'

	local COMMA=p','
	local COLON=p':'
	local DOT=p'.'
	local DOLLAR=p'$'
	local NUM=p'#'
	local QUES=p'?'
	local AT=p'@'
	local PERCENT=p'%'

	local DOTDOT=p'..'
	local DOTDOTDOT=p'...'
	local DOUBLECOLON=p'::'
	local SEMI=p';'


	-- #--------------------Kw-----------------------
	local TRUE=p"true"
	local FALSE=p"false"
	local NIL=p"nil"

	local END=p"end"
	local DO=p"do"

	local WHILE=p"while"
	local FOR=p"for"
	local IN=p"in"
	local REPEAT=p'repeat'
	local UNTIL=p'until'

	local BREAK=p"break"
	local CONTINUE=p"continue"
	local RETURN=p"return"
	local YIELD=p"yield"
	local SPAWN=p"spawn"
	local RESUME = p'resume'
	local WAIT = p'wait'
	local SIGNAL=p'signal'


	local IF=p"if"
	local THEN=p"then"
	local ELSE=p"else"
	local ELSEIF=p"elseif"

	local SELECT=p"select"
	local CASE=p"case"
	local DEFAULT=p"default"

	local CLASS=p"class"
	local EXTENDS=p"extends"
	local ABSTRACT=p"abstract"
	local FINAL=p"final"

	local METHOD=p"method"
	local OVERRIDE=p"override"
	local FIELD=p"field"
	local GET=p"get"
	local SET=p"set"
	local SELF=p"self"
	local SUPER=p"super"
	local IS=p"is"


	local FUNCTION=p"function"
	local FUNC=p"func"

	local FUNCKW = FUNCTION+FUNC

	local OPERATOR=p"operator"
	local GLOBAL=p"global"
	local UPVALUE = p'upvalue'
	local LOCAL=p"local"
	local CONST=p"const"
	local ENUM=p"enum"
	-- local NAMESPACE=p"namespace"

	local PRIVATE=p"private"
	local PUBLIC=p"public"
	local EXTERN=p"extern"

	local TRY=p"try"
	local CATCH=p"catch"
	local THROW=p"throw"
	local FINALLY = p"finally"
	local ASSERT = p"assert"

	local IMPORT=p"import"
	local USING=p"using"

	local NUMBER=p"number"
	local BOOL=p"bool"
	local STRING=p"string"
	local ANY=p"any"

	local AND=p"and"
	local OR=p"or"
	local NOT_KW=p"not"
	local AS=p"as"

	local LT2=p'<<'
	local GT2=p'>>'
	local LT=p'<'
	local GT=p'>'
	local RAWLUA=p'__Lua'

	local Keyword=	
				END+DO
			+	FALSE+NIL+TRUE
			+	SELF+SUPER
			+	LOCAL+FIELD+GLOBAL+CONST+ENUM
			+	ASSERT
			+	AND+OR+NOT_KW+AS
			+	BREAK+CONTINUE+RETURN
			+	IF+THEN+ELSEIF+ELSE
			+	FUNCTION+FUNC+METHOD+OVERRIDE
			+	CLASS+EXTENDS
			+	WHILE+FOR+IN+REPEAT+UNTIL
			+	SELECT+CASE+DEFAULT
			+	TRY+CATCH+THROW+FINALLY
			+	YIELD+SPAWN+SIGNAL+WAIT+RESUME
			+	ABSTRACT+FINAL
			+	RAWLUA
			+	PRIVATE+PUBLIC+EXTERN
			+	IMPORT+USING
			
	local QUOTE=p'"'
	local QUOTES=p"'"

	------------------------CONSTANT

	 
	local StringS= QUOTES * c( (p"\\'"+(1-QUOTES-EOL))^0 )* cassert(QUOTES, "broken string")
	local StringD= QUOTE  * c( (p'\\"'+(1-QUOTE -EOL))^0 )* cassert(QUOTE, "broken string")


	local StringLOpen = "[" * cg(p'='^0, "init") * "[" * EOL^-1
	local StringLClose = "]" * c(p'='^0) * "]"
	local StringLCloseEQ = cmt(StringLClose * cb("init"), function (s, i, a, b) return a == b end)
	local StringL = StringLOpen * c((EOL+(1 - StringLCloseEQ))^0) * cassert(StringLClose,"mismatched long string/block comment") / c1 


	local NegativeSymbol=(MINUS * _ )^-1
	local IntegerCore=NegativeSymbol * DIGIT^1 
	local RationalCore=NegativeSymbol * DIGIT^0 * '.' * #DIGIT* cassert(DIGIT^1,"malformed rational")

	local Integer= c( IntegerCore ) * _
	local Rational=c( RationalCore) * _
	local Exponetional=c( (RationalCore+IntegerCore) * 'e' * cassert(IntegerCore, "malformed exponetional") ) * _
	local HexElem= DIGIT+r('af','AF')
	local Hexdigit = c(p'0x'*cassert(HexElem^1,'malformed hexadecimal'))

	local Number = Hexdigit+Exponetional+Rational+Integer
	local Boolean= c(TRUE+FALSE)

	local cnil	= cc(nil)

	local LineCmt=p'--'*(1-EOL)^0*(EOL+(-p(1)))
	local BlockCmt=p'--'*StringL/function() end --drop captured string

	local COMMENT=BlockCmt+LineCmt

	local __= v.WS
	local _NA=v.NotAlpha
	local SemiEOL=(__ * SEMI * __)^0
	local IdentCore=Name - ( Keyword * -ALPHADIGIT )

	local Ident=v.Ident
	local String=v.String

	local function foldexpr(l,e,...) 
		if e then 
			e.l=l 
			return foldexpr(e,...)
		end
		return l
	end

	local function foldtype(a,b,...)
		if b then
			b.etype=a
			return foldtype(b,...)
		end
		return a
	end

	local function foldmember(a,b,...)
		if b then
			local t={
				tag='member',
				l=a,
				id=b
			}
			return foldmember(t,...)
		end
		return a
	end

	local function w(p) return __*p*__ end

	local pdepth,pstack=0,{}

	POpen=	w(POPEN)*cp()/function(pos) 
		pdepth=pdepth+1
		pstack[pdepth]=pos
	end

	PClose=	cnot(w(PCLOSE),function(pos0,pos1)
		parseErr("unclosed parenthesis ->"..pstack[pdepth],pos1)
	end)

	--GRAMMAR

	local Module=p{
		'M',
		
		WS=(s' \t'+COMMENT+EOL)^0;
		NotAlpha= #(-ALPHA); --not alpha
		Ident= c(IdentCore+(DOTDOTDOT))* __;

		String=(StringS+StringD+StringL) * __;
		
		M = ct(w(v.HeadStmt * SemiEOL)^0) * 
				w(v.Block) * 
				cassert(-p(1),"syntax error") 
				/ 
				t2('module','heads','block')
				;
		
		HeadStmt=
					cpos(
						v.Import +
						v.CommonDirective
						)
					;
		
		Import= w(IMPORT) *__* 
					(	StringS + 
						StringD	+ 
						ct( Name *(DOT*cassert(Name,'module name expected') )^0 )
					) * 
					( w(AS * -p's') * Ident + cnil)
					/ 
					t2('import','src','alias')
					;

		-- ImportWarn=cassert( -v.Import, 'import should be at head of source')
		-- 			;
		
		Block= 	ct((__ * v.Stmt  * SemiEOL  )^0 )/function(a) a.tag="block" return a end ;
		
		-------------END STATEMENTS
		EndStmt=cpos(v.ReturnStmt
				+v.BreakStmt
				+v.ContinueStmt
				+v.ThrowStmt
				) * __
				;
		
		ReturnStmt= (RETURN * __ * v.ReturnValues) /t1('returnstmt','values');
		ReturnValues= (v.ExprList+cnil);
		BreakStmt=w(BREAK) /t0'breakstmt';
		
		ContinueStmt=w(CONTINUE) /t0'continuestmt';
		
		ThrowStmt=THROW * __ * v.ExprList /t1('throwstmt','values');
		
			
	-- #--------------------STATMENTS-------------------

		Stmt	=cpos( 
				v.AssignStmt 
				+ v.ConnectStmt
				+ v.AssertStmt
				+ v.ExprStmt
				+ v.BlockInnerDecls
				+ v.ExternBlock 
				+ v.FlowStmt
				+ v.EndStmt
				+ v.Import
				) * __
				;

		AssertStmt=ASSERT *__ * cassert( v.Expr,'assert expression expected') *
				(COMMA*__ * cassert( v.Expr,'assert exception expected'))^-1
				/t2('assertstmt','expr','exception');


		CommonDirective=PRIVATE * cassert(w(COLON),"':' expected")/t0('private')
					+	PUBLIC * cassert(w(COLON),"':' expected")/t0('public')
					+	RAWLUA * cassert(w(StringL),"long string expected")/t1('rawlua','src')
						;

		ExprStmt=	v.Expr /t1('exprstmt','expr');
		
		-----------------------EXTERN BLOCK
		ExternBlock=EXTERN * __ *
						ct(( v.ExternDecl * __ * SemiEOL)^0)*
					cassert(END , "unclosed extern block")/t1('extern','decls')
					;
				
		ExternDecl=	cpos(v.ConstDecl
				+	v.GlobalDecl/function(vd) vd.extern=true return vd end
				+	v.EnumDecl
				+	v.ExternFuncDecl
				+	v.ExternClassDecl
				+ 	v.CommonDirective)
				;
				
		ExternFuncDecl=FUNCKW *__* v.ExternFuncBody;
						
		ExternFuncBody=	cpos(
						cc(true)*(v.FuncAlias *AS*__ * Ident
						+cnil*Ident)*
						v.FuncType/t4('funcdecl','extern','alias','name','type')
						)
						;
						
		FuncAlias	=(StringS+StringD+IdentCore)*__;
		
		ExternClassDecl=
							v.Annotations * 
							CLASS *__* cc(true)* (v.FuncAlias *AS*__ * Ident
							+cnil*Ident) *
						(EXTENDS * __ * cassert(v.NamedType,'super class name expected')+cnil) *
							(ct(v.ExternClassItemDecl^0)) *
						END /t6('classdecl','ann','extern','alias','name','superclassacc','decls')
						;

		ExternClassItemDecl=
					v.FieldDecl
				+	v.ExternMethodDecl
				+	v.GlobalDecl
				+	v.ExternFuncDecl
				+	v.ConstDecl
				+	v.EnumDecl
				+ v.CommonDirective

				;
				
		ExternMethodDecl=
			v.Annotations *
			METHOD *__* v.ExternFuncBody/function(ann, f) f.ann=ann f.tag='methoddecl' return f end;
					
		
	-- #--------------------Flow Control-------------------
		FlowStmt=	(v.IfStmt
				+	v.WhileStmt				
				+	v.ForEachStmt
				+	v.ForStmt
				+	v.SwitchStmt
				+	v.RepeatStmt
				+	v.DoStmt
				+	v.TryStmt
				+	v.YieldStmt) * __
				;
		YieldStmt= YIELD *__ * (v.ExprList+cnil) / t1('yieldstmt','values');
		
		DoStmt	=	DO * __ * v.Block * cassert(END, "unclosed do block") /t1('dostmt','block');
		
		IfStmt	=	IF *__ * cassert(v.Expr,"condition expression expected") *
					v.ThenBody / t2('ifstmt','cond','body')
					;
					
		ThenBody=	cassert(THEN*__,"'then' expected") *
						v.Block *
					(
						v.ElseIfBody
						+	
						(ELSE * __ * v.Block)^-1 *
						cassert(END , "unclosed if-then block")
					)/t2(nil,'thenbody','elsebody')
					;
					
		ElseIfBody=	ELSEIF * __ * cassert(v.Expr,"condition expression expected") *
					v.ThenBody / t2('ifstmt','cond','body') ;
					
					
		SwitchStmt=	SELECT *__ * cassert(v.Expr,"condition expression expected") *
					ct((CASE * __ * cassert(v.ExprList,"case condition expressions expected") *
						cassert(THEN*__,"'then' expected for 'case'") * 
							v.Block/t2('case','conds','block')
						)^0) *
					(DEFAULT *__ * v.Block) ^-1 *
					cassert(END , "unclosed switch block")/t3('switchstmt','cond','cases','default')
					;
					
		WhileStmt=	WHILE * __ * cassert(v.Expr, "condition expression expected") *
						cassert(DO*__,"'do' expected for 'while'") * 
						v.Block *
					cassert(END , "unclosed while block") 
					/ t2('whilestmt','cond','block')
					;
					
		RepeatStmt=	REPEAT *
						v.Block *
					cassert(UNTIL * __, "'until' expected for 'repeat'") * __ *
						cassert(v.Expr, "condition expression expected") 
					/ t2('repeatstmt','block','cond')
					;
		
		TryStmt	=	TRY * __ * 
						v.Block *
					ct( cassert(v.CatchBody^1, "catch block expected" ) ) *
					(FINALLY * __ * v.Block+cnil ) *
					cassert(END , "unclosed try-catch block") / t3('trystmt','block','catches','final')
					;
					
		CatchBody=	w(CATCH) * cassert(v.TypedVarList, "catch variable expected") * 
						cassert( DO *__ , "'do' expected for 'catch'" ) * 
						cassert(v.Block,"syntax error in catch block") /t2('catch','vars','block')
					;			
					
		ForStmt	=	FOR *__	* cpos(v.NoTypedVar) * 
					#(-IN-COMMA) * cassert(ASSIGN,"'=' expected in for-loop") * __ * 
						ct(cassert(
							v.Expr * COMMA *__ * v.Expr *
							(COMMA * __ * v.Expr )^-1
						,"for loop range error")) *
						cassert(DO*__,"'do' expected for 'for'") * 
						v.Block*
					cassert(END , "unclosed for-loop block")/t3('forstmt','var','range','block')
					;
					
		ForEachStmt= FOR *__ * 
					v.NoTypedVarList *
					IN*__* cassert(v.Expr/t1('iterator','expr'),"iterator expression expected") *
						cassert(DO*__,"'do' expected for 'for'") * 
						v.Block *
					cassert(END , "unclosed foreach-loop block")
					/t3('foreachstmt','vars','iterator','block')
					;

		NoTypedVar	=Ident/t1('var','name')
					;
		NoTypedVarList=ct((v.NoTypedVar * ( COMMA *__* cassert(v.NoTypedVar,"variable expected"))^0)^-1)
					;

		TypedVar	=Ident * v.TypeTag^-1 / t2('var','name','type')
					;
		TypedVarList=ct((v.TypedVar * ( COMMA *__* cassert(v.TypedVar,"variable expected"))^0)^-1)
					;
		
	---------------------------ASSIGN----------------------
		AssignStmt	=	v.AssOpStmt + v.Assign + v.BatchAssign;
		
		AssOpStmt	=	v.Expr	* 
						c(ASSADD + ASSSUB + ASSMUL + ASSDIV+ ASSMOD + ASSPOW + ASSAND + ASSOR + ASSCON) *
						cassert( __ * v.Expr, "expression expected") / t3('assopstmt','var','op','value')
					;
		Assign	=	v.ExprList	*__* v.AssignSymbol * cassert( __ * v.ExprList , "values expected")
					/ t3('assignstmt','vars','autocast','values');
		
		BatchAssign=	v.Expr	* DOT *__*
					POpen* ct( cassert ( Ident* (COMMA * __ * Ident)^0 ,"member names expected")) *PClose *
					v.AssignSymbol * __ * v.ExprList / t4('batchassign','var','members','autocast','values') 
					;

		-- AssignSymbol= w(ASSCAST*cc(true)+ASSIGN*cc(nil));
		AssignSymbol= ASSIGN*cc(nil);
	-------------------------CONNECT SIGNAL-------------------
		ConnectStmt=v.Expr * __ * p'>>'* cassert( __ * v.Expr,'connection slot expected')
					/t2('connectstmt','signal','slot')
					;

	--------------------------Declaration--------------------

		BlockInnerDecls=  
					 v.FuncDecl
					+ v.LocalDecl 
					+ v.ClassDecl
					+ v.ConstDecl
					+ v.GlobalDecl
					+ v.EnumDecl
					+ v.CommonDirective
					+ v.SignalDecl
					;
		
	-------------------Class Declaration-------------------	
						
		ClassInnerDecls=cpos(
					v.FieldDecl	
				+	v.MethodDecl				
				+	v.FuncDecl
				+	v.ConstDecl
				+	v.GlobalDecl
				+	v.EnumDecl
				+ 	v.CommonDirective
				+ 	v.SignalDecl
				)
				;
			
		ClassDecl=	
					v.Annotations *
					CLASS * __ * 
					cassert(
						Ident *
						(ct(LT*__*
							cassert(v.TVar*(COMMA * cassert( __ * v.TVar,'template variable expected'))^0,"template variable expected")*
							cassert(GT*__,"'>' expected"))
						+cnil) 
						,"class name expected")
					*
					(EXTENDS * cassert( __ * v.NamedType,'super class name expected')+cnil) 
					*
					ct( ( __ * v.ClassInnerDecls) ^0 )*
					cassert( __ * END , "unclosed class block")
					/t5('classdecl','ann','name','tvars','superclassacc','decls')
					;
		
		TVar	=	Ident/t1('tvar','name');
		
		-- SuperName=	v.NameSpaceIdent*
		-- 			(ct(LT*__*
		-- 				cassert(v.Type*(COMMA*__*v.Type)^0,"type expected")*
		-- 				cassert(GT*__,"'>' expected"))
		-- 			+cnil)
		-- 			/t2('supername','id','template')
		-- 			;
		
	-- #-------------------Symbol Delcaration-------------------
		SignalDecl=	SIGNAL * cassert( __ * Ident,"signal name expected")*
					cassert(v.ArgList,"signal arguments expected")
					/t2('signaldecl','name','args')
					;

		EnumDecl=v.Annotations * ENUM * cassert( __ * Ident,"enumeration name expected") *
					cassert(BOPEN *__* 
						v.EnumItemList*
						-- ct( v.EnumItem* ( COMMA *__* v.EnumItem )^0 ) *
					BCLOSE *__ , "enum items expected")
					/t3('enumdecl','ann','name','items')
					;
					
		EnumItem=	cpos(Ident *
					(ASSIGN * cassert( __ * v.Expr,"expression expected") + cnil)
					/t2('enumitem','name','value')
					)
					;
		
		EnumItemList=ct(
					v.EnumItem*(w(COMMA)*v.EnumItem)^0
					*w(COMMA)^-1
					+cnil)
					;
		
		LocalDecl=	LOCAL *__*  cpos(v.VarDecl)
						/ function(vd) vd.vtype='local' return vd end
						;
						
		GlobalDecl=	GLOBAL *__* cpos(v.VarDecl)
						/ function(vd) vd.vtype='global' return vd end
						;		
		
		ConstDecl=	CONST *__* cpos(v.VarDecl)
						/ function(vd) vd.vtype='const' return vd end
						;
		
		FieldDecl=	v.Annotations * FIELD *__* cpos(v.VarDecl)
						/ function(ann, vd ) vd.vtype='field' vd.ann=ann return vd end 
						;

		VarDecl=	ct(
							cassert(v.VarDeclBody,"variable expected") * 
							(COMMA * cassert( __ * v.VarDeclBody ,"variable expected"))^0
						)
						*
						(	w(ASSIGN) * v.ExprList
						+	w(ASSDEF) * v.ExprList*cc(true)
						+	cnil
						)/ t3('vardecl','vars','values','def')
						;
		
		VarDeclBody= cpos((Ident* (v.TypeTag + cnil) )/t2('var','name','type'));

		-- AnnotationItem  = cpos(
		-- 						p'@'*__* cassert(Ident, 'annotation class name expected') * __ *
		-- 						(v.SeqBody+v.TableBody+cnil)
		-- 						/t2('annotation', 'name', 'body')
		-- 						)
		-- 						;
		AnnotationItem  = cpos(
								p'@'*__* cassert(v.VarAcc, 'annotation value expected') 
								/t1('annotation', 'value')
								) * __ 
								;
		Annotations = ct(v.AnnotationItem^0);

		MethodDecl	= v.AbstractMethodDecl + v.NormalMethodDecl ;

		AbstractMethodDecl =
								v.Annotations *  ABSTRACT * __ *
								cpos(v.MethodDeclHeader)
							 /function(ann, m) m.ann=ann m.abstract=true return m end
								;

		NormalMethodDecl = v.Annotations * (FINAL*cc(true)+cnil) * __ *
							cpos(v.MethodDeclHeader) *
							v.FuncBlock / 
							function(ann, final, m, block)
								m.ann=ann
								m.final=final
								m.block=block
								return m
							end
							;


		MethodDeclHeader=(METHOD*cnil+OVERRIDE*cc(true)*(__*METHOD)^-1) * __ * 
						cassert(Ident,"method name/operator expected") *
						v.FuncType 
						/t3('methoddecl','override','name','type')
						;
		
		Operators	=s('+-*/%^<>')+ p'>='+p'<='+p'=='+p'~='+p'as'+p'[]'+p'[]=';

		FuncDecl=	(cc(true)*LOCAL+cc(nil))*__* 
					FUNCKW * cassert( __ * Ident ,"function name expected") * __ *
					( AS * cassert( __ * v.FuncAlias, "function alias expected")+cnil ) *
					cassert( v.FuncType, "function type expected" ) * __ *
					v.FuncBlock / t5('funcdecl','localfunc','name','alias','type','block')
					;
		
		FuncBlock=	ASSIGN * cassert( __ * v.ExprList,'expression expected')/t1('exprbody','exprs')
					+	v.Block * cassert( END ,"unclosed function block")
					;
	 
		FuncType=	(v.TypeSymbol+cnil) * __ *
					v.ArgList *
					(w(ARROW) * ct(cassert(
							POpen* v.RetTypeItem * (w(COMMA) * cassert(v.RetTypeItem,"return type expected"))^0 *PClose
						+	v.RetTypeItem * (w(COMMA) * cassert(v.RetTypeItem,"return type expected"))^0
						-- +	v.RetTypeItem * cassert(w(COMMA),"multiple return type must be inside parenthesis")
						,"return type syntax error"))
						+  cnil
					)
					/function(ret0,args,rettype)
						if ret0 and rettype then
							return parseErr('duplicated return type declaration')
						end
						local rt=ret0 and {ret0} or rettype or nil
						if not rt then 
							rt=voidType
						elseif #rt==1 then
							rt=rt[1]
						else
							rt={tag='mulrettype',types=rt}
						end
						
						return {tag='functype', rettype=rt, args=args}
					end
					;

		ArgList	=	POpen *
						ct((v.ArgDef * ( __ * COMMA * cassert( __ * v.ArgDef, "argument expected"))^0 )^-1) *
						PClose 
						;

		ArgDef	=	cpos((Ident+c(DOTDOTDOT)) *__* (v.TypeTag+cnil) *
						(ASSIGN * cassert( __ * v.Expr,"default argument value expected") +cnil)
						/t3('arg','name','type','value'))
						;
			
		RetTypeItem= cpos((Ident * __ * v.TypeTag/function(n,t) t.alias=n return t end)) + v.Type;
			

	---------------------------------------TYPE
		
		TypeTag	=	(COLON *__* v.Type) + #v.TypeSymbol*v.Type;
		
		Type	=	cpos(v.TableType) * __ ;
						
		TableType=	v.TypeCore * 
					(w(SOPEN) * 
						(v.Type+cc('empty')) * 
					cassert(w(SCLOSE),"unclosed squre bracket")
					/t1('tabletype','ktype')
					)^0/foldtype
					;
						
		TypeCore=	v.TypeSymbol
						+	v.NamedType				
						+	POpen*cassert(v.Type,"inner type missing")*PClose
						+	FUNCKW * cassert( __ * v.FuncType, "function type syntax error")
								/function(ft) 
										if type(ft)~='table' then return false end
										ft.typeonly=true
										return ft
									end
						;
		
		NamedType=	cpos(v.TemplateType+(v.NameSpaceIdent+NIL) /t1('type','acc'));
		
		TypeSymbol=	cpos(
							(p'#'/'number'
						+	p'?'/'boolean'
						+	p'$'/'string'
						+	p'*'/'any')*__
						/function(x)
								return {tag='type',acc={tag='varacc', id=x}}
							end
					)
					;
				
		TemplateType=Ident*
					(ct(LT*__*
						cassert(v.Type*(COMMA*__*v.Type)^0,"type expected")*
						cassert(GT*__,"'>' expected"))
					)
					/t2('ttype','name','args')
					;
		
		NameSpaceIdent=
					Ident/t1('varacc','id')
					*(DOT*-DOT*Ident)^0/foldmember
					;
		-- TemplateVar=LT*__*
		-- 				ct(cassert(Ident * (COMMA *__* Ident)^0,"type variable expected")) *
		-- 			cassert(GT*__,"'>' expected")
		-- 			;
					
		-- TemplateVarItem=Ident *(EXTENDS * cassert(Ident,"type name expected") + cnil )/t2('tvar','name','super')
		-- 			;
		
	----------------------Reflection-----------------------------

		MetaData=	p'@'*BOPEN*__* 
					(ct(v.MetaItem * __ *(  COMMA * cassert( __ * v.MetaItem,"metadata item expected"))^0)+cnil) *
					cassert( __* BCLOSE ,"unclosed metadata body") * __
					+cnil
					;
					
		MetaItem=	c(Name) *__* ASSIGN *__* 
				ccheck(
					cassert(v.Expr ,"metadata item value expected"),
					checkConst,
					'metadata item must be constant'
				)/t2('mitem','k','v')
				+	c(Name) *__ /t1('mitem','k')
				;
		
	-- #--------------------Expression-------------------	
		ExprList=ct(v.Expr * ( COMMA * cassert( __ * v.Expr,"expression expected") )^0);
		
		Expr=	cpos(v.Logic) * __;
		
		-- Ternary= v.Logic *
		-- 		(p'?' * __ * v.Ternary *
		-- 			cassert( __ * STICK , "'|' expected") *
		-- 			__ * v.Ternary / t2('ternary','vtrue','vfalse')
		-- 		)^0/foldexpr;
		
		Logic=	v.NotOp * __ *
					(	c(AND+OR) * - ASSIGN *
						cassert(__ * v.NotOp, "right operand expected for logic expr")/t2('binop','op','r')
					)^0/foldexpr
					;

		NotOp=	c(NOT_KW) * cassert( __ * v.NotOp, "operand expected for 'not' expr")/ t2('unop','op','l')
				+v.Compare;
		
		Compare= v.Concat * __ *
					(	c(EQ + NOTEQ + LESSEQ + GREATEQ + GREATER*#(-GREATER) + LESS) *
						cassert(__ * v.Concat, "right operand expected for comparison expr")/t2('binop','op','r')
					)^0/foldexpr
					;
				

		Concat	=v.Sum * __ *
					(	c(DOTDOT) * -ASSIGN *
						cassert(__ * v.Sum, "right operand expected for concat expr")/t2('binop','op','r')
					)^0/foldexpr
					;
		
		Sum		=v.Product * __ *
					cpos(	c(PLUS+MINUS) * -ASSIGN *
						cassert(__ * v.Product, "right operand expected for arith expr")/t2('binop','op','r')
					)^0/foldexpr
					;
				
		Product=v.Unary * __ *
					(	c(STAR+SLASH+PERCENT+POW) * -ASSIGN *
						cassert(__ * v.Unary, "right operand expected for arith expr")/t2('binop','op','r')
					)^0/foldexpr
					;
				
		Unary	= c(MINUS*-Number) * cassert( __ * v.Unary, "operand expected for unary expr") / t2('unop','op','l')
					+ v.Closure
					+ v.VarAcc
					;
		
		VarAcc	=	v.Value * __ *
				cpos(
					w(SOPEN) *  v.Expr * w(SCLOSE) /t1('index','key')--index
				+	DOT * -DOT *__* c(IdentCore) /t1('member','id')		--member
				+	AS * -p's'*__ * cassert(v.Type, 'target type expected') / t1('cast','dst')				--cast
				+	IS * __ * cassert(v.Type, 'checking type expected') / t1('is','dst') 				--typecheck
				+	ct(v.StringConst) / t1('call','args') --string call
				+	POpen * (v.ExprList+cnil) * PClose / t1('call','args')--call
				+	(v.SeqBody+v.TableBody)/t1('tcall','arg')
				
				)^0 / foldexpr
				;
				
		Value = POpen * v.Expr * PClose
				+	v.ValueCore
				;
		
		ValueCore=  
			(p'\\'*cc('global')+p'&'*cc('upvalue')+cnil) * c(IdentCore) /t2('varacc','vartype','id')
			+ c(DOTDOTDOT) / t1('varacc','id')
			+ v.Const
			+ NIL /function() return nilConst end
			+ (p'&'*cc(true)+cc(nil))*SELF /t1('self','upvalue')
			+ SUPER  /t0'super'
			+ v.SeqBody
			+ v.TableBody
			+ v.Spawn
			+ v.Resume
			+ v.Wait
			;
		
		Const = Number/makeNumberConst
			+ v.StringConst
			+ Boolean/function(v) return v=='true' and trueConst or falseConst end
			;
		
		StringConst=w((StringS+StringD)*cc(nil)+StringL*cc(true))/makeStringConst;

		Spawn	=	SPAWN * __ * cassert(v.Expr, "spawn expression expected" )/ t1('spawn','call') ;
		
		Resume	=	RESUME * __ * cassert(v.Expr, "resume expression expected")/t1('resume','thread');

		Wait	=	WAIT * __ * cassert(v.Expr, "signal expected for wait expression")/t1('wait','signal');

		Closure	=	FUNCKW * __ *_NA * cassert(v.FuncType, "function type expected" ) * __ * v.FuncBlock/t2('closure','type','block');
		
		SeqBody	=	w(BOPEN)* 
					ct(v.Expr * (w(COMMA) * v.Expr)^0 *w(COMMA)^-1 + cnil) *
					w(BCLOSE) / t1('seq','items')
					;
		

		TableBody=	w(BOPEN)*				
				v.TableItemList	* 
				cassert(w(BCLOSE),"unclosed table body") / t1('table','items')
				;
			
		TableItem = (Ident/makeStringConst + (w(SOPEN)*v.Expr*w(SCLOSE)))	* 
					ASSIGN * __ * 
					cassert(v.Expr,"table item value expected") / t2('item','key','value')
					;

		TableItemList=ct(
			v.TableItem*(w(COMMA+SEMI)*v.TableItem)^0 *
			w(COMMA+SEMI)^-1
			+
			cnil
			)
			;
		
	}

	lpeg.setmaxstack(800)

	return Module
end


local	function doPreprocessor(code,env)
	local lines={}
	local lineCount=0

	local chunk={}
	local ci=1
	local insert=table.insert
	local format,sub,find=string.format,string.sub,string.find

	for line in string.gmatch(code..'\n',"(.-)\r?\n") do
		lineCount=lineCount+1
		lines[lineCount]=line	
		if find(line,'^#')	 then
			insert(chunk,sub(line,2).."\n")
		else
			insert(chunk,format('__line__[%d]=1\n',lineCount))
		end
	end
	insert(chunk,1,'local __line__=...\n')
	local f=loadstring(table.concat(chunk))
	local index={}
	setfenv(f,env or {})
	f(index)
	for i =1,lineCount do
		if not index[i] then 
			lines[i]='\n'
		else
			lines[i]=lines[i]..'\n'
		end
	end
	return table.concat(lines)
end


 
local ModuleMatch
function parseSource(source,allowError,prepEnv)
	if not ModuleMatch then ModuleMatch=getModuleMatch() end
	resetContext()
	lineOffset={[1]=0}
	currentParsedSource=source
	source=doPreprocessor(source,prepEnv)
	local m= L.match(ModuleMatch,source)
	currentParsedSource=nil
	
	if #errors>0 and not allowError then
		local function printerr(msg)
				io.stderr:write(tostring(msg)..'\n')
			end

		for i,e in ipairs(errors) do
			printerr(e)
		end

		error('[PARSING ERROR]')
	end

	m.lineOffset=lineOffset
	m.file='<string...>'
	
	for i,n in ipairs(m.heads) do
		n.ishead=true
		table.insert(m.block, i, n)
	end

	m.mainfunc={
		tag='funcdecl',
		name='@main',
		module=m,
		p0=m.p0,
		p1=m.p1,
		main=true,
		type={tag='functype',args={},rettype=voidType},
		block=m.block	
	}

	m.block=nil

	return m, errors
end

totalParseTime=0
function parseFile(file,allowError,prepEnv)
	local t1=os.clock()
	currentFilePath=file
	local f=io.open(file,'r')
	assert(f,'file not found:'..file)
	local src=f:read("*a")
	f:close()
	local m, errors = parseSource(src,allowError,prepEnv)
	m.file=file
	totalParseTime=totalParseTime+os.clock()-t1
	return m, errors
end



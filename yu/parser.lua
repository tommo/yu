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
local currentLine=1
local currentLineOffset=0
local currentOffsetTable={0}
local lineInfo={}
local currentFilePath=''
local errors = {}
local function newline(off) 
	currentLine=currentLine+1
	currentLineOffset=off
	lineInfo[currentLine]=off
	currentOffsetTable[currentLine]=off
end

local function resetContext()
	currentLine=1
	currentLineOffset=0
	currentOffsetTable={0}
	lineInfo={}
	errors={}
end

local function checkConst(t)
	local tag=t and t.tag
	return tag and tag=='number' or tag=='boolean' or tag=='string' or tag=='nil'
end

local function parseErr(msg,pos)
	local lpos=pos-currentLineOffset
	local m="parse error@"..currentFilePath.."<"..currentLine..":"..lpos..">:"..msg
	errors[#errors+1]=m
end
	--cmt(p(1),f

local function getModuleMatch()

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

	local function cerr(patt,msg) return cnot(patt,function(s0,s1) 

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
			t.p0=p0
			t.p1=p1 
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
	local FOREVER = p'forever'

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
	local NAMESPACE=p"namespace"

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
			+	WHILE+FOREVER+FOR+IN+REPEAT+UNTIL
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

	 
	local StringS= QUOTES * c( (p"\\'"+(1-QUOTES-EOL))^0 )* cerr(QUOTES, "broken string")
	local StringD= QUOTE  * c( (p'\\"'+(1-QUOTE -EOL))^0 )* cerr(QUOTE, "broken string")


	local StringLOpen = "[" * cg(p'='^0, "init") * "[" * EOL^-1
	local StringLClose = "]" * c(p'='^0) * "]"
	local StringLCloseEQ = cmt(StringLClose * cb("init"), function (s, i, a, b) return a == b end)
	local StringL = StringLOpen * c((1 - StringLCloseEQ)^0) * cerr(StringLClose,"mismatched long string/block comment") / c1 


	local NegativeSymbol=(MINUS * _ )^-1
	local IntegerCore=NegativeSymbol * DIGIT^1 
	local RationalCore=NegativeSymbol * DIGIT^0 * '.' * #DIGIT* cerr(DIGIT^1,"malformed rational")

	local Integer= c( IntegerCore ) * _
	local Rational=c( RationalCore) * _
	local Exponetional=c( (RationalCore+IntegerCore) * 'e' * cerr(IntegerCore, "malformed exponetional") ) * _
	local HexElem= DIGIT+r'af'+r'AF'
	local Hexdigit = c(p'0x'*cerr(HexElem^1,'malformed hexadecimal'))

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
		
		M= ct(w(v.HeadStmt)^0) * w(v.Block) * cerr(-p(1),"syntax error") / t2('module','heads','block');
		
		HeadStmt=cpos(v.Import);
		
		Import= w(IMPORT) *__* 
				(	StringS+StringD
					+ct(Name*(DOT*cerr(Name,'module name expected'))^0)
				)*(__*AS*__*Ident+cnil) / t2('import','src','alias');
		
		
		Block= 	ct((__ * v.Stmt  * SemiEOL )^0 )/function(a) a.tag="block" return a end ;
		
		-------------END STATEMENTS
		EndStmt=cpos(v.ReturnStmt
				+v.BreakStmt
				+v.ContinueStmt
				+v.ThrowStmt
				)
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
				)
				;

		AssertStmt=ASSERT *__ * cerr( v.Expr,'assert expression expected') *
				(COMMA*__ * cerr( v.Expr,'assert exception expected'))^-1
				/t2('assertstmt','expr','exception');


		CommonDirective=PRIVATE * cerr(w(COLON),"':' expected")/t0('private')
					+	PUBLIC * cerr(w(COLON),"':' expected")/t0('public')
					+	RAWLUA * cerr(w(StringL),"long string expected")/t1('rawlua','src')
						;

		ExprStmt=	v.Expr /t1('exprstmt','expr');
		
		-----------------------EXTERN BLOCK
		ExternBlock=EXTERN * __ *
						ct((v.ExternDecl*SemiEOL)^0)*
					cerr(END*__, "unclosed extern block")/t1('extern','decls')
					;
				
		ExternDecl=	cpos(v.ConstDecl
				+	v.GlobalDecl
				+	v.EnumDecl
				+	v.ExternFuncDecl
				+	v.ExternClassDecl
				+ 	v.CommonDirective)
				;
				
		ExternFuncDecl=FUNCKW *__* v.ExternFuncBody;
						
		ExternFuncBody=	cc(true)*(v.FuncAlias *AS*__ * Ident
						+cnil*Ident)*
						v.FuncType/t4('funcdecl','extern','alias','name','type')
						;
						
		FuncAlias	=(StringS+StringD+IdentCore)*__;
		
		ExternClassDecl=CLASS *__* cc(true)* (v.FuncAlias *AS*__ * Ident
							+cnil*Ident) *
						(EXTENDS * __ * cerr(v.SuperName,'super class name expected')+cnil) *
							(ct(v.ExternClassItemDecl^0)) *
						END *__ /t5('classdecl','extern','alias','name','supername','decls')
						;

		ExternClassItemDecl=
					v.FieldDecl
				+	v.ExternMethodDecl
				+	v.GlobalDecl
				+	v.ExternFuncDecl
				+	v.ConstDecl
				+	v.EnumDecl
				+ 	v.CommonDirective

				;
				
		ExternMethodDecl=METHOD *__* v.ExternFuncBody/function(f) f.tag='methoddecl' return f end;
					
		
	-- #--------------------Flow Control-------------------
		FlowStmt=	v.IfStmt
				+	v.WhileStmt				
				+	v.ForeverStmt
				+	v.ForEachStmt
				+	v.ForStmt
				+	v.SwitchStmt
				+	v.RepeatStmt
				+	v.DoStmt
				+	v.TryStmt
				+	v.YieldStmt
				;
		YieldStmt= YIELD *__ * (v.ExprList+cnil) / t1('yieldstmt','values');
		
		DoStmt	=	DO * __ * v.Block * cerr(END*__, "unclosed do block") /t1('dostmt','block');
		
		IfStmt	=	IF *__ * cerr(v.Expr,"condition expression expected") *
					v.ThenBody / t2('ifstmt','cond','body')
					;
					
		ThenBody=	cerr(THEN*__,"'then' expected") *
						v.Block *
					(
						v.ElseIfBody
						+	
						(ELSE * __ * v.Block)^-1 *
						cerr(END * __ , "unclosed if-then block")
					)/t2(nil,'thenbody','elsebody')
					;
					
		ElseIfBody=	ELSEIF * __ * cerr(v.Expr,"condition expression expected") *
					v.ThenBody / t2('ifstmt','cond','body') ;
					
					
		SwitchStmt=	SELECT *__ * cerr(v.Expr,"condition expression expected") *
					ct((CASE * __ * cerr(v.ExprList,"case condition expressions expected") *
						cerr(THEN*__,"'then' expected for 'case'") * 
							v.Block/t2('case','conds','block')
						)^0) *
					(DEFAULT *__ * v.Block) ^-1 *
					cerr(END*__, "unclosed switch block")/t3('switchstmt','cond','cases','default')
					;
					
		WhileStmt=	WHILE * __ * cerr(v.Expr, "condition expression expected") *
						cerr(DO*__,"'do' expected for 'while'") * 
						v.Block *
					cerr(END * __, "unclosed while block") 
					/ t2('whilestmt','cond','block')
					;
					
		RepeatStmt=	REPEAT *
						v.Block *
					cerr(UNTIL * __, "'until' expected for 'repeat'") * __ *
						cerr(v.Expr, "condition expression expected") 
					/ t2('repeatstmt','block','cond')
					;
		
		ForeverStmt=FOREVER*cc(trueConst) *
						v.Block *
					cerr(END * __, "unclosed forever loop block")
					/ t2('whilestmt','cond','block')
					;
					

		TryStmt	=	TRY * __ * 
						v.Block *
					ct( cerr(v.CatchBody^1, "catch block expected" ) ) *
					(FINALLY * __ * v.Block+cnil ) *
					cerr(END * __ , "unclosed try-catch block") / t3('trystmt','block','catches','final')
					;
					
		CatchBody=	w(CATCH) * cerr(v.TypedVarList, "catch variable expected") * 
						cerr( DO *__ , "'do' expected for 'catch'" ) * 
						cerr(v.Block,"syntax error in catch block") /t2('catch','vars','block')
					;			
					
		ForStmt	=	FOR *__	* cpos(v.NoTypedVar) * 
					#(-IN-COMMA) * cerr(ASSIGN,"'=' expected in for-loop") * __ * 
						ct(cerr(
							v.Expr * COMMA *__ * v.Expr *
							(COMMA * __ * v.Expr )^-1
						,"for loop range error")) *
						cerr(DO*__,"'do' expected for 'for'") * 
						v.Block*
					cerr(END*__, "unclosed for-loop block")/t3('forstmt','var','range','block')
					;
					
		ForEachStmt= FOR *__ * 
					v.NoTypedVarList *
					IN*__* cerr(v.Expr/t1('iterator','expr'),"iterator expression expected") *
						cerr(DO*__,"'do' expected for 'for'") * 
						v.Block *
					cerr(END*__, "unclosed foreach-loop block")
					/t3('foreachstmt','vars','iterator','block')
					;

		NoTypedVar	=Ident/t1('var','name')
					;
		NoTypedVarList=ct((v.NoTypedVar * ( COMMA *__* cerr(v.NoTypedVar,"variable expected"))^0)^-1)
					;

		TypedVar	=Ident * v.TypeTag^-1 / t2('var','name','type')
					;
		TypedVarList=ct((v.TypedVar * ( COMMA *__* cerr(v.TypedVar,"variable expected"))^0)^-1)
					;
		
	---------------------------ASSIGN----------------------
		AssignStmt	=	v.AssOpStmt + v.Assign + v.BatchAssign;
		
		AssOpStmt	=	v.Expr	* 
						c(ASSADD + ASSSUB + ASSMUL + ASSDIV+ ASSMOD + ASSPOW + ASSAND + ASSOR + ASSCON) *__ *
						cerr(v.Expr, "expression expected") / t3('assopstmt','var','op','value')
					;
		Assign	=	v.ExprList	*__* v.AssignSymbol *__*	cerr(v.ExprList , "values expected")
					/ t3('assignstmt','vars','autocast','values');
		
		BatchAssign=	v.Expr	* DOT *__*
					POpen* ct(cerr(Ident* (COMMA * __ * Ident)^0 ,"member names expected")) *PClose *
					v.AssignSymbol * v.ExprList / t4('batchassign','var','members','autocast','values') 
					;

		-- AssignSymbol= w(ASSCAST*cc(true)+ASSIGN*cc(nil));
		AssignSymbol=w(ASSIGN*cc(nil));
	-------------------------CONNECT SIGNAL-------------------
		ConnectStmt=v.Expr * __ * p'>>'* __ * cerr(v.Expr,'connection slot expected')
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
			
		ClassDecl=	CLASS * __ * 
					cerr(Ident*
						(ct(LT*__*
							cerr(v.TVar*(COMMA*__*cerr(v.TVar,'template variable expected'))^0,"template variable expected")*
							cerr(GT*__,"'>' expected"))
						+cnil) 
					,"class name expected") *
					(EXTENDS * __ * cerr(v.SuperName,'super class name expected')+cnil) *
					v.MetaData *
						ct(v.ClassInnerDecls^0)*
					cerr(END *__, "unclosed class block")
					/t5('classdecl','name','tvars','supername','meta','decls');
		
		TVar	=	Ident/t1('tvar','name');
		
		SuperName=	Ident*
					(ct(LT*__*
						cerr(v.Type*(COMMA*__*v.Type)^0,"type expected")*
						cerr(GT*__,"'>' expected"))
					+cnil)
					/t2('supername','id','template')
					;
		
	-- #-------------------Symbol Delcaration-------------------
		SignalDecl=	SIGNAL *__* cerr(Ident,"signal name expected")*
					cerr(v.ArgList,"signal arguments expected")
					/t2('signaldecl','name','args')
					;

		EnumDecl=	ENUM *__* cerr(Ident,"enumeration name expected") *
					cerr(BOPEN *__* 
						ct( v.EnumItem* ( COMMA *__* v.EnumItem )^0 ) *
					BCLOSE *__ , "enum items expected")
					/t2('enumdecl','name','items')
					;
					
		EnumItem=	cerr(Ident,"enum item name expected") *
					(ASSIGN *__ * cerr(v.Expr,"expression expected") + cnil)
					/t2('enumitem','name','value')
					;
		
		LocalDecl=	LOCAL *__*  v.VarDecl
						/ function(vd) vd.vtype='local' return vd end;
						
		GlobalDecl=	GLOBAL *__* v.VarDecl
						/ function(vd) vd.vtype='global' return vd end;
		
		ConstDecl=	CONST *__* v.VarDecl
						/ function(vd) vd.vtype='const' return vd end;
		
		FieldDecl=	FIELD *__* v.VarDecl * v.MetaData
						/ function(vd,meta) vd.vtype='field' vd.meta=meta return vd end 
					-- 	*
					-- ( v.GetterBody*v.SetterBody
					-- + v.SetterBody*v.GetterBody *cc(true))
					-- /function(fd,g,s,setterFirst) 
					-- 	if setterFirst then g,s=s,g end
					-- 	fd.getter=g 
					-- 	fd.setter=s 
					-- 	return fd 
					-- end
					;

		-- UpvalueDecl= UPVALUE *__* cerr(ct(v.Ident*(COMMA*__*v.Ident)^0),"upvalue name expected")
		-- 				/t1('upvalue','vars')
		-- 			;

		-- GetterBody= p'::get' *__* cerr(v.FuncBlock,"property getter block expected") +cnil;
		-- SetterBody= p'::set' *__* cerr(v.FuncBlock,"property setter block expected") +cnil;
		
		VarDecl=	ct(
							cerr(v.VarDeclBody,"variable expected") * 
							(COMMA *__* cerr(v.VarDeclBody ,"variable expected"))^0
					)
					*
					(	w(ASSIGN) * v.ExprList
					+	w(ASSDEF) * v.ExprList*cc(true)
					+	cnil
					)/ t3('vardecl','vars','values','def')
					;
		
		VarDeclBody= cpos((Ident* (v.TypeTag + cnil) )/t2('var','name','type'));
						
		MethodDecl	=(METHOD*cnil+OVERRIDE*cc(true)*(__*METHOD)^-1) * __ * 
						cerr(Ident,"method name/operator expected") *
						v.FuncType
						/t3('methoddecl','override','name','type')
						*
						(	ABSTRACT * cc('abstract') * __ * v.MetaData
						+	FINAL*cc('final')*__* v.MetaData * v.FuncBlock
						+	cnil* v.MetaData * v.FuncBlock					
						)/function(head,mtype,meta,block) 
							head.meta=meta 
							head.abstract=mtype=='abstract'
							head.final=mtype=='final'
							head.block=block
							return head 
						end
						;
		
		Operators	=s('+-*/%^<>')+ p'>='+p'<='+p'=='+p'~='+p'as'+p'[]'+p'[]=';

		FuncDecl=	(cc(true)*LOCAL+cc(nil))*__* 
					FUNCKW * __ * cerr(Ident ,"function name expected") * __ *
					( AS *__ * cerr(v.FuncAlias, "function alias expected")+cnil ) *
					cerr(v.FuncType,"function type expected")* __ *
					v.FuncBlock / t5('funcdecl','localfunc','name','alias','type','block');
		
		FuncBlock=	ARROWE *__* cerr(v.ExprList,'expression expected')/t1('exprbody','exprs')
				+	v.Block * cerr(END *__,"unclosed function block");
	 
		FuncType=	(v.TypeSymbol+cnil) * 
					v.ArgList *
					(w(ARROW) * ct(cerr(
							POpen* v.RetTypeItem * (w(COMMA) * cerr(v.RetTypeItem,"return type expected"))^0 *PClose
						+	v.RetTypeItem * (w(COMMA) * cerr(v.RetTypeItem,"return type expected"))^0
						-- +	v.RetTypeItem * cerr(w(COMMA),"multiple return type must be inside parenthesis")
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
						ct((v.ArgDef * (w(COMMA)* cerr(v.ArgDef, "argument expected"))^0 )^-1) *
					PClose 
					;

		ArgDef	=	cpos((Ident+c(DOTDOTDOT)) *__* (v.TypeTag+cnil)
						/t2('arg','name','type'))
					;
			
		RetTypeItem= cpos((Ident *__* v.TypeTag/function(n,t) t.alias=n return t end)) + v.Type;
			

	---------------------------------------TYPE
		
		TypeTag	=	(COLON *__* v.Type) + #v.TypeSymbol*v.Type;
		
		Type	=	cpos(v.TableType);
						
		TableType=	v.TypeCore * 
						(w(SOPEN) * 
							(v.Type+cc('empty')) * 
						cerr(w(SCLOSE),"unclosed squre bracket")
						/t1('tabletype','ktype')
						)^0/foldtype
					;
						
		TypeCore=	v.TypeSymbol
				+	v.NamedType				
				+	POpen*cerr(v.Type,"inner type missing")*PClose
				+	FUNCKW *__* cerr(v.FuncType, "function type syntax error")
						/function(ft) 
								if type(ft)~='table' then return false end
								ft.typeonly=true
								return ft
							end;
		
		NamedType=	cpos(v.TemplateType+Ident /t1('type','name'));
		
		TypeSymbol=	cpos(
						(p'#'/'number'
					+	p'?'/'boolean'
					+	p'$'/'string'
					+	p'*'/'any')*__
					/t1('type','name')
				)
				;
				
		TemplateType=Ident*
					(ct(LT*__*
						cerr(v.Type*(COMMA*__*v.Type)^0,"type expected")*
						cerr(GT*__,"'>' expected"))
					)
					/t2('ttype','name','args')
					;
					
		-- TemplateVar=LT*__*
		-- 				ct(cerr(Ident * (COMMA *__* Ident)^0,"type variable expected")) *
		-- 			cerr(GT*__,"'>' expected")
		-- 			;
					
		-- TemplateVarItem=Ident *(EXTENDS * cerr(Ident,"type name expected") + cnil )/t2('tvar','name','super')
		-- 			;
		
	----------------------Reflection-----------------------------

		MetaData=	p':'*BOPEN*__* 
					(ct(v.MetaItem * __ *(  COMMA *__ * cerr(v.MetaItem,"metadata item expected"))^0)+cnil) *__*
					cerr(BCLOSE*__,"unclosed metadata body")/makeMetaData
					+cnil
					;
					
		MetaItem=	c(Name) *__* ASSIGN *__* 
				ccheck(
					cerr(v.Expr ,"metadata item value expected"),
					checkConst,
					'metadata item must be constant'
				)/t2('mitem','k','v')
				+	c(Name) *__ /t1('mitem','k')
					;
		
	-- #--------------------Expression-------------------	
		ExprList=ct(v.Expr * ( COMMA *__* cerr(v.Expr,"expression expected") )^0);
		
		Expr=	cpos(v.Ternary);
		
		Ternary= v.Logic *
				(p'?' * __ * v.Ternary *
					cerr( __ * STICK , "'|' expected") *
					__ * v.Ternary / t2('ternary','vtrue','vfalse')
				)^0/foldexpr;
		
		Logic=	v.NotOp *
				(	c(AND+OR) * - ASSIGN *
					cerr(__ * v.NotOp, "right operand expected for logic expr")/t2('binop','op','r')
				)^0/foldexpr;

		NotOp=	c(NOT_KW) * cerr( __ * v.NotOp, "operand expected for 'not' expr")/ t2('unop','op','l')
				+v.Compare;
		
		Compare= v.Concat *
				(	c(EQ + NOTEQ + LESSEQ + GREATEQ + GREATER*#(-GREATER) + LESS) *
					cerr(__ * v.Concat, "right operand expected for comparison expr")/t2('binop','op','r')
				)^0/foldexpr;
				

		Concat	=v.Sum *
				(	c(DOTDOT) * -ASSIGN *
					cerr(__ * v.Sum, "right operand expected for concat expr")/t2('binop','op','r')
				)^0/foldexpr;
		
		Sum		=v.Product *
				(	c(PLUS+MINUS) * -ASSIGN *
					cerr(__ * v.Product, "right operand expected for arith expr")/t2('binop','op','r')
				)^0/foldexpr;
				
		Product=v.Unary *
				(	c(STAR+SLASH+PERCENT+POW) * -ASSIGN *
					cerr(__ * v.Unary, "right operand expected for arith expr")/t2('binop','op','r')
				)^0/foldexpr;
				
		Unary	= c(MINUS*-Number) * cerr( __ * v.Unary, "operand expected for unary expr") / t2('unop','op','l')
				+ v.Closure
				+ v.VarAcc;
		
		VarAcc	=	v.Value *
				cpos(
					w(SOPEN) *  v.Expr * w(SCLOSE) /t1('index','key')--index
				+	DOT * -DOT *__* Ident /t1('member','id')		--member
				+	AS * __ * v.Type / t1('cast','dst')				--cast
				+	IS * __ * v.Type / t1('is','dst') 				--typecheck
				+	ct(v.StringConst) / t1('call','args') --string call
				+	POpen * (v.ExprList+cnil) * PClose / t1('call','args')--call
				+	(v.SeqBody+v.TableBody)/t1('tcall','arg')
				
				)^0 / foldexpr
				;
				
		Value = POpen * v.Expr * PClose
			+	v.ValueCore;
		
		ValueCore=  cpos((p'\\'*cc('global')+p'@'*cc('upvalue')+cnil) * Ident * __ /t2('varacc','vartype','id')
			+ v.Const * __
			+ NIL *__ /function() return nilConst end
			+ (p'@'*cc(true)+cc(nil))*SELF * __ /t1('self','upvalue')
			+ SUPER * __ /t0'super'
			+ v.SeqBody
			+ v.TableBody
			+ v.Spawn
			+ v.Resume
			+ v.Wait)
			;
		
		Const = Number/makeNumberConst
			+ v.StringConst
			+ Boolean/function(v) return v=='true' and trueConst or falseConst end
			;
		
		StringConst=((StringS+StringD)*cc(nil)+StringL*cc(true))*__/makeStringConst;

		Spawn	=	SPAWN * __ * cerr(v.Expr, "spawn expression expected" )/ t1('spawn','call') ;
		
		Resume	=	RESUME * __ * cerr(v.Expr, "resume expression expected")/t1('resume','thread');

		Wait	=	WAIT * __ * cerr(v.Expr, "signal expected for wait expression")/t1('wait','signal');

		Closure	=	FUNCKW * __ *_NA * cerr(v.FuncType, "function type expected" ) * __ * v.FuncBlock/t2('closure','type','block');
		
		SeqBody	=	w(BOPEN)* 
						(ct(v.Expr*(w(COMMA)*cerr(v.Expr,'expression expected'))^0)+cnil) 
					* w(BCLOSE) / t1('seq','items')	;
		
		TableBody=	w(BOPEN)*
				(	v.TableItem* 
					(__* (COMMA+SEMI) *__* cerr(v.TableItem,"table item expected"))^0 * __ * (COMMA+SEMI)^-1 *__  
				)^-1 * cerr(w(BCLOSE),"unclosed table body") / tt('table','items') ;
			
		TableItem = (Ident/makeStringConst + (w(SOPEN)*v.Expr*w(SCLOSE)))
					* ASSIGN * __* cerr(v.Expr,"table item value expected") / t2('item','key','value');
		
	}

	return Module
end
 
local ModuleMatch
function parseSource(source,allowError)
	if not ModuleMatch then ModuleMatch=getModuleMatch() end
	resetContext()
	lineInfo={[1]=0}
	local m= L.match(ModuleMatch,source)
	
	if #errors>0 and not allowError then
		for i,e in ipairs(errors) do
			print(e)
		end
		error('Parse Failed')
	end

	m.lineInfo=lineInfo
	m.file='<string...>'

	m.mainfunc={
		tag='funcdecl',
		name='__main',
		module=m,
		p0=m.p0,
		p1=m.p1,
		main=true,
		type={tag='functype',args={},rettype=voidType},
		block=m.block	
	}

	m.block=nil

	return m
end

totalParseTime=0
function parseFile(file,allowError)
	local t1=os.clock()
	currentFilePath=file
	local f=io.open(file,'r')
	assert(f,'file not found:'..file)
	local src=f:read("*a")
	f:close()
	local m=parseSource(src,allowError)
	m.file=file
	totalParseTime=totalParseTime+os.clock()-t1
	return m
end



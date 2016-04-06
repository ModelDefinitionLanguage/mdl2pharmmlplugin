package eu.ddmore.mdl.utils

import eu.ddmore.mdl.mdl.BlockStatement
import eu.ddmore.mdl.mdl.MdlFactory
import eu.ddmore.mdllib.mdllib.MdlLibFactory
import eu.ddmore.mdl.mdl.EnumPair
import eu.ddmore.mdl.mdl.AssignPair
import eu.ddmore.mdllib.mdllib.Expression
import eu.ddmore.mdl.mdl.SymbolReference
import eu.ddmore.mdl.mdl.BlockStatementBody
import eu.ddmore.mdl.mdl.EquationDefinition
import eu.ddmore.mdllib.mdllib.SymbolDefinition
import eu.ddmore.mdl.mdl.VectorLiteral
import java.util.List
import eu.ddmore.mdl.mdl.SubListExpression
import java.util.Map
import eu.ddmore.mdl.mdl.ValuePair
import eu.ddmore.mdllib.mdllib.TypeDefinition

class MDLBuildFixture {
	val public static String REAL_TYPE_NAME = "Real"
	val TypeDefinition realType

	new(){
		realType = MdlLibFactory.eINSTANCE.createTypeDefinition
		realType.name = REAL_TYPE_NAME
	}


	def BlockStatement createBlock(String blkName, ValuePair ... args){
		val retVal = MdlFactory.eINSTANCE.createBlockStatement
		val blkDefn = MdlLibFactory.eINSTANCE.createBlockDefinition
		blkDefn.name = blkName
		retVal.blkId = blkDefn
		retVal.body = MdlFactory.eINSTANCE.createBlockStatementBody
		if(args.size > 0){
			retVal.blkArgs = MdlFactory.eINSTANCE.createBlockArguments
			for(a : args){
				retVal.blkArgs.args.add(a)
			}
		}
		retVal
	}
	
	def EnumPair createEnumPair(String name, String value){
		val retVal = MdlFactory.eINSTANCE.createEnumPair
		retVal.argumentName = name
		val enumExpr =  MdlFactory.eINSTANCE.createEnumExpression
		enumExpr.enumValue = value
		retVal.expression = enumExpr
		retVal
	}
	
	def AssignPair createAssignPair(String name, Expression exprVal){
		val retVal = MdlFactory.eINSTANCE.createAssignPair
		retVal.argumentName = name
		retVal.expression = exprVal
		retVal
	}
	
	def SymbolReference createSymbolRef(BlockStatement it, String name){
		createSymbolRef(createEqnDefn(name))
	}
	
	def SymbolReference createSymbolRef(SymbolDefinition sd){
		val retVal = MdlFactory.eINSTANCE.createSymbolReference
		retVal.ref = sd
		retVal
	}
	
	def EquationDefinition createEqnDefn(BlockStatement it, String name){
		val bdy = body as BlockStatementBody
		val sd = MdlFactory.eINSTANCE.createEquationDefinition
		sd.name = name
		bdy.statements.add(sd)
		sd
	}

	def EquationDefinition createEqnDefn(BlockStatement it, String name, Expression expr){
		val bdy = body as BlockStatementBody
		val sd = MdlFactory.eINSTANCE.createEquationDefinition
		sd.name = name
		sd.expression = expr
		bdy.statements.add(sd)
		sd
	}

	def VectorLiteral createVectorLiteral(List<Expression> elements){
		val retVal = MdlFactory.eINSTANCE.createVectorLiteral
		for(el : elements){
			val vEl = MdlFactory.eINSTANCE.createVectorElement
			vEl.element = el
			retVal.expressions.add(vEl)
		}
		retVal
	}

	def SubListExpression createSublist(Map<String, Expression> content){
		val retVal = MdlFactory.eINSTANCE.createSubListExpression
		for(key : content.keySet){
			val att = MdlFactory.eINSTANCE.createValuePair
			att.argumentName = key
			att.expression = content.get(key)
			retVal.attributes.add(att)
		}
		retVal
	}
	
	
	def createAnonList(BlockStatement it, List<ValuePair> vps){
		val bdy = body as BlockStatementBody
		val retVal = MdlFactory.eINSTANCE.createAnonymousListStatement
		retVal.list = createAttributeList(vps)
		bdy.statements.add(retVal)
		retVal
	}

	def createAttributeList(BlockStatement it, List<ValuePair> vps){
		val retVal = MdlFactory.eINSTANCE.createAttributeList
		retVal.attributes.addAll(vps)
		return retVal
	}

	def createListDefn(BlockStatement it, String listName, List<ValuePair> vps){
		val bdy = body as BlockStatementBody
		val retVal = MdlFactory.eINSTANCE.createListDefinition
		retVal.name = listName
		retVal.list = createAttributeList(vps)
		bdy.statements.add(retVal)
		retVal
	}


	def createRandVar(BlockStatement it, String varName, SymbolReference distn){
		val bdy = body as BlockStatementBody
		val retVal = MdlFactory.eINSTANCE.createRandomVariableDefinition
		retVal.name = varName
		retVal.distn = distn
		bdy.statements.add(retVal)
		retVal
	}

	def createNamedFunction(String varName, List<ValuePair> argVals){
		val funcDefn = MdlLibFactory.eINSTANCE.createFunctionDefnBody
		funcDefn.name = varName
		funcDefn.funcSpec = MdlLibFactory.eINSTANCE.createFunctionSpec
		val argDefn = MdlLibFactory.eINSTANCE.createNamedFuncArgs
		funcDefn.funcSpec.argument = argDefn
		for(vp : argVals){
			val arg = MdlLibFactory.eINSTANCE.createFuncArgumentDefinition
			arg.name = vp.argumentName
			arg.typeSpec = createSimpleTypeSpec(realType)
			argDefn.arguments.add(arg)
		}
		val retVal = MdlFactory.eINSTANCE.createSymbolReference
		retVal.ref = funcDefn
		val namedArgs = MdlFactory.eINSTANCE.createNamedFuncArguments
		retVal.argList = namedArgs
		for(vp : argVals){
			namedArgs.arguments.add(vp)
		}
		retVal
	}
	
	def createSimpleTypeSpec(TypeDefinition td){
		val retVal = MdlLibFactory.eINSTANCE.createTypeSpec
		retVal.typeName = td
		retVal
	}
	
	def createRealLiteral(double realVal){
		val retVal = MdlFactory.eINSTANCE.createRealLiteral
		retVal.value = realVal
		retVal
	}

	def createStringLiteral(String strVal){
		val retVal = MdlFactory.eINSTANCE.createStringLiteral
		retVal.value = strVal
		retVal
	}
	
	def createIntLiteral(int intVal){
		val retVal = MdlFactory.eINSTANCE.createIntegerLiteral
		retVal.value = intVal
		retVal
	}
	
	def createBooleanLiteral(boolean isTrueFlag){
		val retVal = MdlFactory.eINSTANCE.createBooleanLiteral
		retVal.isTrue = isTrueFlag
		retVal
	}
	
}
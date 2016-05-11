package eu.ddmore.converter.mdl2pharmml08

import eu.ddmore.mdl.mdl.EquationTypeDefinition

class SimpleParameterWriter extends AbstractIndivParamWriter {
	extension PharmMLExpressionBuilder pcu = new PharmMLExpressionBuilder

	def writeParameter(EquationTypeDefinition it)'''
		<Parameter symbId="«name»">
			«IF expression != null»
				«expression.expressionAsAssignment»
			«ENDIF»
		</Parameter>
	'''
		
	
}
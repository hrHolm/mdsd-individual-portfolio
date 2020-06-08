package dk.sdu.mmmi.generator

import dk.sdu.mmmi.springBoard.Plus
import dk.sdu.mmmi.springBoard.Minus
import dk.sdu.mmmi.springBoard.Mult
import dk.sdu.mmmi.springBoard.Div
import dk.sdu.mmmi.springBoard.BoolAnd
import dk.sdu.mmmi.springBoard.BoolOr
import dk.sdu.mmmi.springBoard.Lt
import dk.sdu.mmmi.springBoard.Gt
import dk.sdu.mmmi.springBoard.Eq
import dk.sdu.mmmi.springBoard.Lteq
import dk.sdu.mmmi.springBoard.Gteq
import dk.sdu.mmmi.springBoard.Neq
import dk.sdu.mmmi.springBoard.Var
import dk.sdu.mmmi.springBoard.NumConst
import dk.sdu.mmmi.springBoard.Compare
import dk.sdu.mmmi.springBoard.StrConst

class InvariantGenerator {

	def dispatch CharSequence genExp(BoolAnd logic) '''(«logic.left.genExp» && «logic.right.genExp»)'''

	// bangs in front of or-expressions, in order to introduce double negation
	def dispatch CharSequence genExp(BoolOr logic) '''(«logic.left.genExp» || «logic.right.genExp»)'''

	def dispatch CharSequence genExp(Compare logic) '''(«logic.left.genExp» «logic.op.genOp» «logic.right.genExp»)'''

	def dispatch CharSequence genExp(Plus exp) '''«exp.left.genExp» + «exp.right.genExp»'''

	def dispatch CharSequence genExp(Minus exp) '''«exp.left.genExp» - «exp.right.genExp»'''

	def dispatch CharSequence genExp(Mult exp) '''«exp.left.genExp» * «exp.right.genExp»'''

	def dispatch CharSequence genExp(Div exp) '''«exp.left.genExp» / «exp.right.genExp»'''

	def dispatch CharSequence genExp(Var exp) '''«exp.variable.name»'''

	def dispatch CharSequence genExp(NumConst exp) '''«exp.value»'''
	
	def dispatch CharSequence genExp(StrConst exp) '''"«exp.value»"'''

	def dispatch CharSequence genOp(Lt operator) '''<'''

	def dispatch CharSequence genOp(Gt operator) '''>'''

	def dispatch CharSequence genOp(Eq operator) '''=='''

	def dispatch CharSequence genOp(Lteq operator) '''<='''

	def dispatch CharSequence genOp(Gteq operator) '''>='''

	def dispatch CharSequence genOp(Neq operator) '''!='''

}

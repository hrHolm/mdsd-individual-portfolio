package dk.sdu.mmmi.generator

import dk.sdu.mmmi.springBoard.Plus
import dk.sdu.mmmi.springBoard.Minus
import dk.sdu.mmmi.springBoard.Mult
import dk.sdu.mmmi.springBoard.Div
import dk.sdu.mmmi.springBoard.Num
import dk.sdu.mmmi.springBoard.BoolAnd
import dk.sdu.mmmi.springBoard.BoolOr
import dk.sdu.mmmi.springBoard.Requirement
import dk.sdu.mmmi.springBoard.Lt
import dk.sdu.mmmi.springBoard.Gt
import dk.sdu.mmmi.springBoard.Eq
import dk.sdu.mmmi.springBoard.Lteq
import dk.sdu.mmmi.springBoard.Gteq
import dk.sdu.mmmi.springBoard.Neq
import dk.sdu.mmmi.springBoard.Var

class InvariantGenerator {
	
	def dispatch CharSequence genLogic(BoolAnd logic) '''(«logic.left.genLogic»&&«logic.right.genLogic»)'''
	def dispatch CharSequence genLogic(BoolOr logic) '''(«logic.left.genLogic»||«logic.right.genLogic»)'''
	def dispatch CharSequence genLogic(Requirement logic) '''(«logic.left.genExp»«logic.op.genOp»«logic.right.genExp»)'''
	
	
	def dispatch CharSequence genExp(Plus exp) {
		'''«exp.left.genExp» + «exp.right.genExp»'''
	}
	
	def dispatch CharSequence genExp(Minus exp) {
		'''«exp.left.genExp» - «exp.right.genExp»'''
	}
	
	def dispatch CharSequence genExp(Mult exp) {
		'''«exp.left.genExp» * «exp.right.genExp»'''
	} 
	
	def dispatch CharSequence genExp(Div exp) {
		'''«exp.left.genExp» / «exp.right.genExp»'''
	}
	
	def dispatch CharSequence genExp(Var exp) {
		'''«exp.variable.name»'''
	} 
	
	def dispatch CharSequence genExp(Num exp) {
		'''«exp.value»'''
	}
	
	def dispatch CharSequence genOp(Lt operator) {
		return "<"
	}
	
	def dispatch CharSequence genOp(Gt operator) {
		return ">"
	}
	
	def dispatch CharSequence genOp(Eq operator) {
		return "=="
	}
	
	def dispatch CharSequence genOp(Lteq operator) {
		return "<="
	}
	
	def dispatch CharSequence genOp(Gteq operator) {
		return ">="
	}
	
	def dispatch CharSequence genOp(Neq operator) {
		return "!="
	}
}
package dk.sdu.mmmi.validation
import dk.sdu.mmmi.springBoard.Plus
import dk.sdu.mmmi.springBoard.Minus
import dk.sdu.mmmi.springBoard.Mult
import dk.sdu.mmmi.springBoard.Div
import dk.sdu.mmmi.springBoard.BoolAnd
import dk.sdu.mmmi.springBoard.BoolOr
import dk.sdu.mmmi.springBoard.Var
import dk.sdu.mmmi.springBoard.NumConst
import dk.sdu.mmmi.springBoard.Exp
import dk.sdu.mmmi.springBoard.StrConst
import dk.sdu.mmmi.springBoard.BoolConst
import dk.sdu.mmmi.springBoard.Compare
import static dk.sdu.mmmi.validation.ExpressionsType.*
import dk.sdu.mmmi.springBoard.Bool
import dk.sdu.mmmi.springBoard.Str
import dk.sdu.mmmi.springBoard.Int

class LogicTyping {
	
	def dispatch ExpressionsType typeFor(Exp e) {
		switch (e) {
			StrConst: STRING_TYPE
			NumConst: INT_TYPE
			BoolConst: BOOL_TYPE
			Mult: INT_TYPE
			Div: INT_TYPE
			Minus: INT_TYPE
			Compare: BOOL_TYPE
			BoolAnd: BOOL_TYPE
			BoolOr: BOOL_TYPE
			Var: variableType(e)
		}
	}
	
	def ExpressionsType variableType(Var v) {
		switch (v.variable.type) {
			Bool : BOOL_TYPE
			Str : STRING_TYPE
			Int : INT_TYPE
		}
	}
	
	def dispatch ExpressionsType typeFor(Plus e) {
		val leftType = e.left.typeFor
		val rightType = e.right?.typeFor
		if (leftType === STRING_TYPE || rightType === STRING_TYPE) {
			return STRING_TYPE
		} else {
			return INT_TYPE
		}
	}

}


enum ExpressionsType {
	STRING_TYPE,
	INT_TYPE,
	BOOL_TYPE
}

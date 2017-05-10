import Foundation

struct Stack<T> {
    var array = [T]()

    public var count: Int {
        return array.count
    }

    public var isEmpty: Bool {
        return array.isEmpty
    }

    public mutating func push(_ element: T) {
        array.append(element)
    }

    @discardableResult
    public mutating func pop() -> T? {
        return array.popLast()
    }

    public var top: T? {
        return array.last
    }
}

let LEFT_PARENTHESIS = "("
let RIGHT_PARENTHESIS = ")"

enum MathExpressionError: Error {
    case mismatchedParenthesis
    case insufficientValues
    case tooManyValues
    case variableValueMissing
}

enum MathTokenType {
    case OPERATOR
    case NUMBER
    case VARIABLE
    case LEFT_PARENTHESIS
    case RIGHT_PARENTHESIS
}

protocol MathToken: CustomStringConvertible {
    var type: MathTokenType { get }
}

struct LeftParenthesis: MathToken {
    var type: MathTokenType {
        return .LEFT_PARENTHESIS
    }
    var description: String {
        return "("
    }
}

struct RightParenthesis: MathToken {
    var type: MathTokenType {
        return .RIGHT_PARENTHESIS
    }
    var description: String {
        return ")"
    }
}

struct Number: MathToken {
    let value: Double
    var type: MathTokenType {
        return .NUMBER
    }

    init(value: Double) {
        self.value = value
    }

    var description: String {
        return String(value)
    }
}

struct Variable: MathToken {
    let value: String
    var type: MathTokenType {
        return .VARIABLE
    }

    init(value: String) {
        self.value = value
    }

    var description: String {
        return value
    }
}

enum Associativity {
    case RIGHT
    case LEFT
}

protocol Operator: MathToken {
    var operatorSymbol: String  { get }
    var operatorPrecedence: Int { get }
    var operatorAssociativity: Associativity { get }

    func evaluate(_ a: Double, _ b: Double) -> Double
}

struct PlusOperator: Operator {
    let operatorSymbol: String
    let operatorPrecedence: Int
    let operatorAssociativity: Associativity

    var type: MathTokenType {
        return .OPERATOR
    }
    var description: String {
        return "\(operatorSymbol)"
    }

    init() {
        self.operatorSymbol = "+"
        self.operatorPrecedence = 1
        self.operatorAssociativity = .LEFT
    }

    func evaluate(_ a: Double, _ b: Double) -> Double {
        return a + b
    }
}

struct MinusOperator: Operator {
    let operatorSymbol: String
    let operatorPrecedence: Int
    let operatorAssociativity: Associativity

    var type: MathTokenType {
        return .OPERATOR
    }
    var description: String {
        return "\(operatorSymbol)"
    }

    init() {
        self.operatorSymbol = "-"
        self.operatorPrecedence = 1
        self.operatorAssociativity = .LEFT
    }

    func evaluate(_ a: Double, _ b: Double) -> Double {
        return a - b
    }
}

struct MultiplicationOperator: Operator {
    let operatorSymbol: String
    let operatorPrecedence: Int
    let operatorAssociativity: Associativity

    var type: MathTokenType {
        return .OPERATOR
    }
    var description: String {
        return "\(operatorSymbol)"
    }

    init() {
        self.operatorSymbol = "*"
        self.operatorPrecedence = 2
        self.operatorAssociativity = .LEFT
    }

    func evaluate(_ a: Double, _ b: Double) -> Double {
        return a * b
    }
}

struct DivisionOperator: Operator {
    let operatorSymbol: String
    let operatorPrecedence: Int
    let operatorAssociativity: Associativity

    var type: MathTokenType {
        return .OPERATOR
    }
    var description: String {
        return "\(operatorSymbol)"
    }

    init() {
        self.operatorSymbol = "/"
        self.operatorPrecedence = 2
        self.operatorAssociativity = .LEFT
    }

    func evaluate(_ a: Double, _ b: Double) -> Double {
        return a / b
    }
}

struct PowerOperator: Operator {
    let operatorSymbol: String
    let operatorPrecedence: Int
    let operatorAssociativity: Associativity

    var type: MathTokenType {
        return .OPERATOR
    }
    var description: String {
        return "\(operatorSymbol)"
    }

    init() {
        self.operatorSymbol = "^"
        self.operatorPrecedence = 3
        self.operatorAssociativity = .RIGHT
    }

    func evaluate(_ a: Double, _ b: Double) -> Double {
        return pow(a, b)
    }
}

let LEGAL_OPERATORS: [String: Operator] = [
    "+": PlusOperator(),
    "-": MinusOperator(),
    "*": MultiplicationOperator(),
    "/": DivisionOperator(),
    "^": PowerOperator()
]

extension String {
    func removeWhitespaces() -> String {
        return self.components(separatedBy: .whitespaces).joined()
    }
}

protocol StringTokenizer {
    func generateTokens(from expression: String) -> [String]
}

class MathExpressionTokenizer: StringTokenizer {

    var result  = [String]()
    var currentNumber = ""

    func generateTokens(from expression: String) -> [String] {
        cleanPreviousState()

        for character in expression.characters {
            if isDigit(character) || isDecimalDot(character) {
                addToCurrentNumber(character)
            } else {
                appendCurrentNumberToResult()
                result.append(String(character))
            }
        }

        appendCurrentNumberToResult()
        return result
    }

    func cleanPreviousState() {
        result.removeAll()
        currentNumber = ""
    }

    func isDigit(_ symbol: Character) -> Bool {
        if let _ = Int(String(symbol)) {
            return true
        }
        return false
    }

    func isDecimalDot(_ symbol: Character) -> Bool {
        return symbol == "."
    }

    func addToCurrentNumber(_ char: Character) {
        currentNumber.append(char)
    }

    func appendCurrentNumberToResult() {
        if !currentNumber.isEmpty {
            result.append(currentNumber)
            currentNumber = ""
        }
    }
}


protocol Parser {
    func parse(expression: [String]) throws -> [MathToken]
}

class ReversePolishNotationParser: Parser {

    var stack = Stack<MathToken>()
    var output = [MathToken]()

    func parse(expression: [String]) throws -> [MathToken] {
        cleanPreviousState()
        return try toRPN(expression)
    }

    func cleanPreviousState() {
        stack = Stack<MathToken>()
        output.removeAll()
    }

    func toRPN(_ expression: [String]) throws -> [MathToken] {
        for token in expression {
            if let value = Double(token) {
                output.append(Number(value:value))
            } else if let leftParenthesis = asLeftParenthesis(token) {
                stack.push(leftParenthesis)
            } else if let _ = asRightParenthesis(token) {
                while stackIsNotEmpty() && stackTopType(isNot: .LEFT_PARENTHESIS) {
                    output.append(stack.pop()!)
                }

                if stackIsEmpty() {
                    throw MathExpressionError.mismatchedParenthesis
                }
                stack.pop()
            } else if let currentOperator = asOperator(token) {

                while stackIsNotEmpty(), let topOperator = stack.top! as? Operator {
                    if (currentOperator.operatorAssociativity == .LEFT && currentOperator.operatorPrecedence <= topOperator.operatorPrecedence) ||
                        (currentOperator.operatorAssociativity == .RIGHT && currentOperator.operatorPrecedence < topOperator.operatorPrecedence) {
                            output.append(stack.pop()!)
                    } else {
                        break
                    }
                }
                stack.push(currentOperator)
            } else if isVariable(token) {
                output.append(Variable(value:token))
            }
        }
        while stackIsNotEmpty() {
            let current = stack.pop()!
            if current.type == .LEFT_PARENTHESIS || current.type == .RIGHT_PARENTHESIS {
                throw MathExpressionError.mismatchedParenthesis
            } else {
                output.append(current)
            }
        }
        return output
    }

    func asLeftParenthesis(_ symbol: String) -> LeftParenthesis? {
        if symbol == LEFT_PARENTHESIS {
            return LeftParenthesis()
        }
        return nil
    }

    func asRightParenthesis(_ symbol: String) -> RightParenthesis? {
        if symbol == RIGHT_PARENTHESIS {
            return RightParenthesis()
        }
        return nil
    }

    func stackIsEmpty() -> Bool {
        return stack.isEmpty
    }

    func stackIsNotEmpty() -> Bool{
        return !stackIsEmpty()
    }

    func stackTopType(isNot type: MathTokenType) -> Bool {
        return stack.top?.type != type
    }

    func asOperator(_ symbol: String) -> Operator? {
        if let mathOperator = LEGAL_OPERATORS[symbol] {
            return mathOperator
        }
        return nil
    }

    func isVariable(_ symbol: String) -> Bool {
        let letters = CharacterSet.letters

        return symbol.characters.count == 1 && letters.contains(symbol.unicodeScalars.first!)
    }
}

protocol Solver {
    func solve(_ tokens: [MathToken], with variables: [String: Double]) throws -> Double
}

class ReversePolishNotationSolver: Solver {

    var stack = Stack<Double>()
    var variables: [String: Double] = [:]

    func solve(_ tokens: [MathToken], with variables: [String: Double]) throws -> Double {
        stack = Stack<Double>()
        self.variables = variables
        return try fromRPN(tokens)
    }

    func fromRPN(_ tokens: [MathToken]) throws -> Double {

        for token in tokens {
            if token.type == .NUMBER {
                let number = asNumber(token)
                stack.push(number.value)
            } else if token.type == .OPERATOR {
                if stack.count < 2 {
                    throw MathExpressionError.insufficientValues
                }
                let value = evaluateOperator(token)
                stack.push(value)
            } else if token.type == .VARIABLE {
                if let value = evaluateVariable(token) {
                    stack.push(value)
                } else {
                    throw MathExpressionError.variableValueMissing
                }

            }
        }
        if stack.count != 1 {
            throw MathExpressionError.tooManyValues
        }
        return stack.pop()!
    }

    func asNumber(_ token: MathToken) -> Number {
        return token as! Number
    }

    func evaluateOperator(_ token: MathToken) -> Double {
        let mathOperator = token as! Operator
        let first = stack.pop()!
        let second = stack.pop()!
        return mathOperator.evaluate(second, first)
    }

    func evaluateVariable(_ token: MathToken) -> Double? {
        let variable = token as! Variable
        let value = variable.value
        return variables[value]
    }

}

protocol Calculator {
    func evaluate(expression: String, with variables: [String: Double]) throws -> Double
}

class SimpleCalculator: Calculator {

    let tokenizer: StringTokenizer
    let parser: Parser
    let solver: Solver

    init(tokenizer: StringTokenizer, parser: Parser, solver: Solver) {
        self.tokenizer = tokenizer;
        self.parser = parser
        self.solver = solver
    }

    func evaluate(expression: String, with variables: [String: Double] = [:]) throws -> Double {
            let stringTokens = tokenizer.generateTokens(from: expression)
            let mathTokens = try parser.parse(expression: stringTokens)
            return try solver.solve(mathTokens, with: variables)
    }
}





func evaluate(expression: String, with variables: [String: Double] = [:]) {
    let calc = SimpleCalculator(tokenizer: MathExpressionTokenizer(),
                                parser: ReversePolishNotationParser(),
                                solver: ReversePolishNotationSolver())

    do {
        let result = try calc.evaluate(expression: expression, with: variables)
        print(result)
    } catch MathExpressionError.mismatchedParenthesis {
        print("There are mismatched parenthesis")
    } catch MathExpressionError.insufficientValues {
        print("There are insufficient values")
    } catch MathExpressionError.tooManyValues {
        print("There are too many values")
    } catch MathExpressionError.variableValueMissing {
        print("Missing variable value")
    } catch {
        print(error)
    }

}



evaluate(expression: "(a + b + c) * 2",
         with: ["a" : 1,
                "b" : 1,
                "c" : 7])

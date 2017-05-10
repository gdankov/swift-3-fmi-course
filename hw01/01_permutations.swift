func permutations(of str: String) -> [String] {
      return heapAlgorithm(str)
}

func heapAlgorithm(_ str: String) -> [String]{
    let strLength = str.characters.count;
    var charArray = Array(str.characters)

    var result = [String]()
    result.append(str)

    var intArr = Array(repeating:0, count:strLength)

    var i = 0
    while i < strLength {
        if intArr[i] < i {
            if isEven(number: i) {
                swap(&charArray[0], &charArray[i])
            } else {
                swap(&charArray[intArr[i]], &charArray[i])
            }
            result.append(String(charArray))
            intArr[i] += 1
            i = 0
        } else {
            intArr[i] = 0
            i += 1
        }
    }

    return result
}

func isEven(number: Int) -> Bool {
    return number % 2 == 0
}

var result = permutations(of:"ABC")
print(result)

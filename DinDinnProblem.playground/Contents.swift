func repeatString(_ str: String, nTimes: inout UInt8) {

    var newString: String = ""
    for c in str {
        let asciiValue = c.asciiValue ?? 0
        var k = nTimes

        let nextValue = asciiValue + nTimes
        
        if nextValue > 122 {
            k -= (122 - asciiValue)
            k = k % 26
            newString += String(Character(UnicodeScalar(96 + k)))
        } else {
            newString += String(Character(UnicodeScalar(nextValue)))
        }
    }
    
    print(newString)
}

var input1: UInt8 = 28
repeatString("abc", nTimes: &input1)
// output: cde

var input2: UInt8 = 1
repeatString("abc", nTimes: &input2)
// output: bcd

var input3: UInt8 = 2
repeatString("abc", nTimes: &input3)
// output: cde

func main(console: TextConsole) async throws {
    
    let input = try await console.read("Enter a number")
    let num = Int(input) ?? 0
    for i in 0...num {
        
        try await console.write("\(i) iteration")
    }
}

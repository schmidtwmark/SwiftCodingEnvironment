func turtleMain(console: TurtleConsole) async throws {
    
    let turtle = try await console.addTurtle()
    let turtle2 = try await console.addTurtle()
    try await turtle2.penDown()
    try await turtle.penDown()
    try await turtle.rotate(30.0)
    try await turtle.forward(50)
    try await turtle2.forward(100)
    try await turtle.arc(radius: 40.0, angle: 270.0)
    try await turtle.setColor(.red)
    try await turtle.forward(100)
    try await turtle.arc(radius: 40.0, angle: 270.0)
    try await turtle.forward(100)
    try await turtle.arc(radius: 40.0, angle: -270.0)
    try await turtle.forward(200)
    try await turtle.arc(radius: 40.0, angle: -30.0)
    try await turtle.forward(200)
}

import Testing

@testable import TemplateAppCore

struct GreetingTests {
    @Test func greetsByTrimmedName() {
        #expect(Greeting(name: "  Ada ").text == "Hello, Ada!")
    }

    @Test func fallsBackWithoutAName() {
        #expect(Greeting(name: " ").text == "Hello!")
    }
}

@IsTest
private class CalculatorTests {

    @IsTest
    static void testDivideByZero() {
        Test.startTest();
        try {
            Decimal result = Calculator.divide(10, 0);
            System.assert(false, 'Expected Calculator.CalculatorException to be thrown.');
        } catch (Calculator.CalculatorException e) {
            System.assert(e.getMessage().contains('divide by zero'),
                'Unexpected exception message: ' + e.getMessage());
        }
        Test.stopTest();
    }
}
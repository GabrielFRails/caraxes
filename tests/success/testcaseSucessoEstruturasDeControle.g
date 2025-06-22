/* Programa que le um numero e informa se e positivo ou negativo. */
/* O laco continua ate que o numero 0 seja digitado. */

int numero;

programa {
    leia numero;
    enquanto (numero) execute {
        se (numero > 0) entao {
            escreva "O numero e positivo.";
            novalinha;
        } senao {
            escreva "O numero e negativo.";
            novalinha;
        }
        leia numero;
    }
}
/* Funcao para calcular o fatorial de um numero n de forma recursiva.
*/
int fatorial(int n) {
    se (n == 0) entao
        retorne 1;
    senao
        retorne n * fatorial(n-1);
}

programa {
    int valor;
    escreva "Digite um numero para calcular o fatorial: ";
    novalinha;
    leia valor;
    
    se (valor >= 0) entao {
        escreva "O fatorial de ";
        escreva valor;
        escreva " e: ";
        escreva fatorial(valor);
        novalinha;
    } senao {
        escreva "Nao e possivel calcular o fatorial de um numero negativo.";
        novalinha;
    }
}
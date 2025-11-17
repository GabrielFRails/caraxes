Perguntas ao Alex:
a) Eu entendo que há três mecanismos distintos aos quais artigos diferente atribuem o mesmo nome que é score de atenção.
Um dos mecanismos, que é o que você usa no seu método que consiste no produto interno entre um  vetor de termos de um documento e os pesos da MLM, gerando uma projeção do vetor em uma distribuição de probabilidade no vocabulário de tokens. Depois agrega um valor único para cada token correspondente ao vetor.
O segundo, talent diferente, é o proposto por Liu et al que consiste em representar os vetores de termos como uma matriz e computa os produtos internos entre eles e depois gera uma distribuição de probabilidade também de cada vetor de termo estar relacionado a um token do vocabulário
Há ainda um terceiro escore que também é denominado score por atenção, mas ao contrário dos demais não usa os vetores de termos, mas sim apenas a MLM.


b) Por que nos experimentos você usou recall@100, quando a maioria dos artigos usa recall@1k? Fica sem condição de comparação com outros trabalhos. Para um retriever, recall é o mais importante. 

c) Durante o fine-tuning os pesos do BERT e da MLM são alterados?
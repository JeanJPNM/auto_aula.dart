let autoProva = {
  checkAnswers(string) {
    var result = string.match(/a|b|c|d|e/gi);
    console.log(result);
  },
  compareAnswers(...answers) {
    var results = answers.map((answer) => answer.match(/a|b|c|d|e/gi));
    console.log(results);
  },
  responder(dados = "", seed = -1) {
    const indexes = { a: 0, b: 1, c: 2, d: 3, e: 4 };
    dados = dados.toLowerCase();
    if (typeof seed != "number") seed = Number(seed);
    if (seed == -1) {
      var id = document.querySelector("input.multiple-choice-question").id;
      var substring = id.split("_")[1];
      seed = Number(substring);
    }
    var respostas = dados.match(/a|b|c|d|e/gi);
    console.log(respostas);
    try {
      function preencher(seed, resposta) {
        while (true) {
          const selector = `input#mc-ans-_${seed}_1_${indexes[resposta]}`;
          const input = document.querySelector(selector);
          if (input != null) {
            if (!input.checked) {
              input.click();
            }
            return seed;
          } else seed++;
        }
      }
      for (const resposta of respostas) {
        seed = preencher(seed, resposta);
        seed++;
      }
    } catch (e) {
      console.error(e);
    }
    return "funcionou";
  },
  testInputs() {
    var inputs = document.querySelectorAll("input.multiple-choice-question");
    for (const input of inputs) {
      console.log(input.id);
    }
  },
};
autoProva.responder("c e d c d e c b d e");

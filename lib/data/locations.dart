import '../models/location_model.dart';
import '../models/dialog_model.dart';

// TODO: substituir latitude/longitude pelos valores reais coletados no campus
// TODO: adicionar musicPath quando os arquivos de áudio estiverem em assets/audio/
// TODO: adicionar characterImage nos DialogSteps quando as imagens estiverem em assets/chars/
const List<LocationModel> locations = [
  LocationModel(
    id: '1',
    name: 'Estacionamento',
    description: 'Entrada do campus da PUC-Campinas.',
    sequence: 1,
    latitude: -23.5000,
    longitude: -46.6000,
    radius: 10.0,
    imagePath: 'assets/estacionamento.png',
    // musicPath: 'assets/audio/estacionamento.mp3',
    unlockHint:
        'O segurança mencionou algo sobre a biblioteca guardar segredos do campus...',
    dialogs: [
      DialogStep(
        speaker: 'Segurança',
        // characterImage: 'assets/chars/seguranca.png',
        text:
            'Ei, você aí! Para! Quem é você e o que está fazendo aqui?',
        options: [
          DialogOption(text: 'Sou estudante, pode deixar.', nextStep: 1),
          DialogOption(text: 'Estou procurando algo importante.', nextStep: 2),
        ],
      ),
      DialogStep(
        speaker: 'Segurança',
        text:
            'Estudante, hein? Pode entrar. Mas fica esperto — esse campus tem segredos que poucos conhecem. Dizem que a biblioteca guarda um deles...',
      ),
      DialogStep(
        speaker: 'Segurança',
        text:
            'Importante? Aqui no estacionamento não tem nada não. Mas se é segredo que você procura, tente a biblioteca.',
      ),
    ],
  ),
  LocationModel(
    id: '2',
    name: 'Biblioteca',
    description: 'Biblioteca da PUC-Campinas.',
    sequence: 2,
    latitude: -23.5010,
    longitude: -46.6010,
    radius: 10.0,
    imagePath: 'assets/biblioteca.jpeg',
    // musicPath: 'assets/audio/biblioteca.mp3',
    unlockHint:
        'A bibliotecária sugeriu investigar o prédio H15 para encontrar mais pistas...',
    dialogs: [
      DialogStep(
        speaker: 'Bibliotecária',
        // characterImage: 'assets/chars/bibliotecaria.png',
        text: 'Bem-vindo à biblioteca. Posso ajudar com alguma coisa?',
        options: [
          DialogOption(
              text: 'Procuro informações sobre o campus.', nextStep: 1),
          DialogOption(text: 'Só estou explorando.', nextStep: 2),
        ],
      ),
      DialogStep(
        speaker: 'Bibliotecária',
        text:
            'Os registros mais antigos foram transferidos para o H15. Talvez você encontre o que procura por lá.',
      ),
      DialogStep(
        speaker: 'Bibliotecária',
        text:
            'Explorando, claro. Se quiser continuar, o prédio H15 tem algo interessante. Poucos estudantes vão até lá.',
      ),
    ],
  ),
  LocationModel(
    id: '3',
    name: 'H15',
    description: 'Prédio H15 da PUC-Campinas.',
    sequence: 3,
    latitude: -23.5020,
    longitude: -46.6020,
    radius: 10.0,
    imagePath: 'assets/H15.jpeg',
    // musicPath: 'assets/audio/h15.mp3',
    unlockHint:
        'O professor falou sobre um encontro na praça de alimentação...',
    dialogs: [
      DialogStep(
        speaker: 'Professor',
        // characterImage: 'assets/chars/professor.png',
        text:
            'Você chegou até aqui. Interessante. O que te trouxe a este corredor esquecido?',
        options: [
          DialogOption(text: 'Estou seguindo as pistas.', nextStep: 1),
          DialogOption(text: 'Alguém me mandou aqui.', nextStep: 2),
        ],
      ),
      DialogStep(
        speaker: 'Professor',
        text:
            'As pistas... você é mais perspicaz do que parece. O que você busca está próximo. Vá à praça de alimentação.',
      ),
      DialogStep(
        speaker: 'Professor',
        text:
            'Sábio da parte deles. Não direi mais nada — vá à praça de alimentação. Você vai entender quando chegar lá.',
      ),
    ],
  ),
  LocationModel(
    id: '4',
    name: 'Praça de Alimentação',
    description: 'Refeitório da PUC-Campinas.',
    sequence: 4,
    latitude: -23.5030,
    longitude: -46.6030,
    radius: 10.0,
    imagePath: 'assets/praca_alimentacao.jpeg',
    // musicPath: 'assets/audio/praca.mp3',
    unlockHint:
        'O vendedor mencionou o jardim das Manacas como o destino final da sua jornada...',
    dialogs: [
      DialogStep(
        speaker: 'Vendedor',
        // characterImage: 'assets/chars/vendedor.png',
        text: 'Ei, você é o aventureiro, não é? Estava te esperando. Senta aí.',
        options: [
          DialogOption(text: 'Como você sabe quem eu sou?', nextStep: 1),
          DialogOption(text: 'Sim, sou eu. O que tem pra me falar?', nextStep: 1),
        ],
      ),
      DialogStep(
        speaker: 'Vendedor',
        text:
            'Nesse campus, todo mundo sabe de tudo. Ouça: sua jornada está quase no fim. O jardim das Manacas — é lá que tudo começa e termina. Vá até lá.',
      ),
    ],
  ),
  LocationModel(
    id: '5',
    name: 'Manacas',
    description: 'Jardim das Manacas.',
    sequence: 5,
    latitude: -23.5040,
    longitude: -46.6040,
    radius: 10.0,
    imagePath: 'assets/manacas.jpeg',
    // musicPath: 'assets/audio/manacas.mp3',
    dialogs: [
      DialogStep(
        speaker: 'Voz misteriosa',
        text:
            'Você chegou até aqui. Atravessou o campus, seguiu as pistas, falou com todos.',
      ),
      DialogStep(
        speaker: 'Voz misteriosa',
        text:
            'Sua jornada não é sobre um destino — é sobre os caminhos que você escolheu percorrer. Até a próxima aventura, explorador.',
      ),
    ],
  ),
];

import '../models/location_model.dart';

// TODO: substituir latitude/longitude pelos valores reais
const List<LocationModel> locations = [
  LocationModel(
    id: '1',
    name: 'Estacionamento',
    description: 'Estacionamento da PUC',
    sequence: 1,
    latitude: -23.5000,
    longitude: -46.6000,
    radius: 10.0,
  ),
  LocationModel(
    id: '2',
    name: 'Biblioteca',
    description: 'Biblioteca',
    sequence: 2,
    latitude: -23.5010,
    longitude: -46.6010,
    radius: 10.0,
  ),
  LocationModel(
    id: '3',
    name: 'H15',
    description: 'Prédio H15',
    sequence: 3,
    latitude: -23.5020,
    longitude: -46.6020,
    radius: 10.0,
  ),
  LocationModel(
    id: '4',
    name: 'Praça de Alimentação',
    description: 'Refeitório',
    sequence: 4,
    latitude: -23.5030,
    longitude: -46.6030,
    radius: 10.0,
  ),
  LocationModel(
    id: '5',
    name: 'Manacas',
    description: 'Manacas',
    sequence: 5,
    latitude: -23.5040,
    longitude: -46.6040,
    radius: 10.0,
  ),
];

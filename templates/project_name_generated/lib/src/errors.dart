class EasyServerException implements Exception {
  int responsecode;

  EasyServerException(this.responsecode);

  @override
  String toString() {
    return 'EasyServerClientError: $responsecode';
  }
}

class ModelException implements Exception {
  @override
  String toString() {
    return 'ModelExeption: failed to convert json into model';
  }
}

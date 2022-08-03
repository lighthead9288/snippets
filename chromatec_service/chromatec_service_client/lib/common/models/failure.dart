import 'package:chromatec_service/common/models/data_status.dart';

abstract class Failure extends DataStatus {}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
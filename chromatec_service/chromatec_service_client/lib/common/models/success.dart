import 'package:chromatec_service/common/models/data_status.dart';

abstract class Success extends DataStatus {}

class DataFromServerSuccess extends Success {}

class DataFromCacheSuccess extends Success {}
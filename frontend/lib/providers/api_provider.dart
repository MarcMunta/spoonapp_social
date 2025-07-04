import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../utils/config.dart';

final apiServiceProvider = Provider((ref) => ApiService(apiBaseUrl));


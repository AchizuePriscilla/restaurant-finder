import 'package:dartz/dartz.dart';

import 'package:restaurant_finder/domain/errors/failure.dart';

typedef Result<T> = Either<Failure, T>;


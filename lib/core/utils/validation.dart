/// 验证规则接口
abstract class ValidationRule<T> {
  String get errorMessage;
  bool validate(T value);
}

/// 验证结果
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({required this.isValid, this.errors = const []});

  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.invalid(List<String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }

  factory ValidationResult.singleError(String error) {
    return ValidationResult(isValid: false, errors: [error]);
  }
}

/// 字段验证器
class FieldValidator<T> {
  final String fieldName;
  final List<ValidationRule<T>> rules;

  FieldValidator(this.fieldName, this.rules);

  ValidationResult validate(T value) {
    final errors = <String>[];

    for (final rule in rules) {
      if (!rule.validate(value)) {
        errors.add('$fieldName: ${rule.errorMessage}');
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}

/// 对象验证器
class ObjectValidator {
  final List<FieldValidator> validators;

  ObjectValidator(this.validators);

  ValidationResult validate() {
    final allErrors = <String>[];

    // 这里需要具体的值，在实际使用时会被重写
    // for (final validator in validators) {
    //   // 验证逻辑
    // }

    return allErrors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(allErrors);
  }
}

// ============ 常用验证规则 ============

/// 必填验证
class RequiredRule<T> implements ValidationRule<T?> {
  @override
  String get errorMessage => '此字段为必填项';

  @override
  bool validate(T? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}

/// 字符串长度验证
class StringLengthRule implements ValidationRule<String?> {
  final int? minLength;
  final int? maxLength;

  StringLengthRule({this.minLength, this.maxLength});

  @override
  String get errorMessage {
    if (minLength != null && maxLength != null) {
      return '长度必须在 $minLength 到 $maxLength 个字符之间';
    } else if (minLength != null) {
      return '长度不能少于 $minLength 个字符';
    } else if (maxLength != null) {
      return '长度不能超过 $maxLength 个字符';
    }
    return '长度不符合要求';
  }

  @override
  bool validate(String? value) {
    if (value == null) return true; // null值由RequiredRule处理

    final length = value.length;
    if (minLength != null && length < minLength!) return false;
    if (maxLength != null && length > maxLength!) return false;
    return true;
  }
}

/// 邮箱验证
class EmailRule implements ValidationRule<String?> {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  String get errorMessage => '请输入有效的邮箱地址';

  @override
  bool validate(String? value) {
    if (value == null || value.isEmpty) return true;
    return _emailRegex.hasMatch(value);
  }
}

/// URL验证
class UrlRule implements ValidationRule<String?> {
  @override
  String get errorMessage => '请输入有效的URL地址';

  @override
  bool validate(String? value) {
    if (value == null || value.isEmpty) return true;
    try {
      final uri = Uri.parse(value);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

/// 数字范围验证
class NumberRangeRule implements ValidationRule<num?> {
  final num? min;
  final num? max;

  NumberRangeRule({this.min, this.max});

  @override
  String get errorMessage {
    if (min != null && max != null) {
      return '数值必须在 $min 到 $max 之间';
    } else if (min != null) {
      return '数值不能小于 $min';
    } else if (max != null) {
      return '数值不能大于 $max';
    }
    return '数值不符合要求';
  }

  @override
  bool validate(num? value) {
    if (value == null) return true;
    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;
    return true;
  }
}

/// 正则表达式验证
class RegexRule implements ValidationRule<String?> {
  final RegExp regex;
  final String message;

  RegexRule(this.regex, this.message);

  @override
  String get errorMessage => message;

  @override
  bool validate(String? value) {
    if (value == null || value.isEmpty) return true;
    return regex.hasMatch(value);
  }
}

/// 自定义验证规则
class CustomRule<T> implements ValidationRule<T> {
  final bool Function(T value) validator;
  final String message;

  CustomRule(this.validator, this.message);

  @override
  String get errorMessage => message;

  @override
  bool validate(T value) => validator(value);
}

// ============ 模型验证器 ============

/// AI提供商验证器
class AiProviderValidator {
  static ValidationResult validateName(String? name) {
    return FieldValidator('提供商名称', [
      RequiredRule<String>(),
      StringLengthRule(minLength: 1, maxLength: 50),
    ]).validate(name);
  }

  // static ValidationResult validateApiKey(String? apiKey) {
  //   return FieldValidator('API密钥', [
  //     RequiredRule<String>(),
  //     StringLengthRule(minLength: 10),
  //   ]).validate(apiKey);
  // }

  static ValidationResult validateBaseUrl(String? baseUrl) {
    if (baseUrl == null || baseUrl.isEmpty) {
      return ValidationResult.valid(); // 可选字段
    }

    return FieldValidator('基础URL', [UrlRule()]).validate(baseUrl);
  }

  static ValidationResult validateProvider({
    required String? name,
    required String? apiKey,
    String? baseUrl,
  }) {
    final errors = <String>[];

    final nameResult = validateName(name);
    if (!nameResult.isValid) errors.addAll(nameResult.errors);

    // 不校验 KEY
    // final apiKeyResult = validateApiKey(apiKey);
    // if (!apiKeyResult.isValid) errors.addAll(apiKeyResult.errors);

    final baseUrlResult = validateBaseUrl(baseUrl);
    if (!baseUrlResult.isValid) errors.addAll(baseUrlResult.errors);

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}

/// AI助手验证器
class AiAssistantValidator {
  static ValidationResult validateName(String? name) {
    return FieldValidator('助手名称', [
      RequiredRule<String>(),
      StringLengthRule(minLength: 1, maxLength: 50),
    ]).validate(name);
  }

  static ValidationResult validateSystemPrompt(String? prompt) {
    return FieldValidator('系统提示词', [
      StringLengthRule(maxLength: 10000),
    ]).validate(prompt);
  }

  static ValidationResult validateTemperature(double? temperature) {
    return FieldValidator('温度参数', [
      NumberRangeRule(min: 0.0, max: 2.0),
    ]).validate(temperature);
  }

  static ValidationResult validateMaxTokens(int? maxTokens) {
    return FieldValidator('最大令牌数', [
      NumberRangeRule(min: 1, max: 100000),
    ]).validate(maxTokens);
  }

  static ValidationResult validateAssistant({
    required String? name,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) {
    final errors = <String>[];

    final nameResult = validateName(name);
    if (!nameResult.isValid) errors.addAll(nameResult.errors);

    final promptResult = validateSystemPrompt(systemPrompt);
    if (!promptResult.isValid) errors.addAll(promptResult.errors);

    final tempResult = validateTemperature(temperature);
    if (!tempResult.isValid) errors.addAll(tempResult.errors);

    final tokensResult = validateMaxTokens(maxTokens);
    if (!tokensResult.isValid) errors.addAll(tokensResult.errors);

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}

/// 消息验证器
class MessageValidator {
  static ValidationResult validateContent(String? content) {
    return FieldValidator('消息内容', [
      RequiredRule<String>(),
      StringLengthRule(minLength: 1, maxLength: 50000),
    ]).validate(content);
  }

  static ValidationResult validateAuthor(String? author) {
    return FieldValidator('消息作者', [
      RequiredRule<String>(),
      StringLengthRule(minLength: 1, maxLength: 100),
    ]).validate(author);
  }

  static ValidationResult validateRole(String? role) {
    if (role == null || role.isEmpty) {
      return ValidationResult.invalid(['消息角色: 不能为空']);
    }

    const validRoles = ['user', 'assistant', 'system'];
    if (!validRoles.contains(role)) {
      return ValidationResult.invalid(['消息角色: 必须是 user、assistant 或 system 之一']);
    }

    return ValidationResult.valid();
  }
}

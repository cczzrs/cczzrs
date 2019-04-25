---
title: python 后端 django rest framework(简称 drf) 开发
tags: [python, django, drf]
author: cczzrs
date: 2019-04-25 08:24:57
updated: 2019-04-25 08:24:57
categories: APP1
---

## python 后端 django rest framework(简称 drf) 开发

> ##### 我这里只讲一些比较重要的难点，本人也是边学边开发的（codeing 是很快的，一半以上的时间都用来学习了）。

> #### http 请求进程流程概况： http 请求 <=> urls.py 中配置转发 <=> views.py 对应处理类及方法 <=> serializers.py 对应处理类及方法 <=> DB 数据库
> #### 按照这个流程开发即快速又高效，前后打通之后，分分钟就能完成一个功能模块的增删改查需求（真的是分分钟哦），
> #### 请用 jwt 的身份认证，后台管理可以用 xadmin（目前只能支持 django2.0及以下版本），xadmin 模块的问题需要手动修复的。
  
  * #### models.py 基本使用，对应的数据库的表
```python
from django.db import models
from django.contrib.auth.models import AbstractUser


class UserAccount(AbstractUser):

    """
    用户账户信息模型
    """
    GENDER = (('man', u"男"), ('girl', "女"), ('null', "未知"))
    JOB = (('boos', u"老板"), ('white-collar', "白领"), ('worker', "打工"), ('student', "学生"), ('hobos', "无业游民"))
    USERACCOUNT_STATUS = ((0, u"失效"), (1, u"有效"))

    avatar = models.ImageField(upload_to="images/avatar/", null=True, blank=True, verbose_name="头像")
    bji = models.ImageField(upload_to="images/bji/", null=True, blank=True, verbose_name="背景图")
    username = models.CharField(max_length=16, unique=True, blank=False, verbose_name="昵称")
    id = models.AutoField(db_column='ID', primary_key=True)
    password = models.CharField(max_length=256, null=True, verbose_name="密码")
    mobile = models.CharField(max_length=11, unique=True, blank=False, verbose_name="手机号")
    gender = models.CharField(max_length=4, choices=GENDER, default='null', verbose_name="性别")
    job = models.CharField(max_length=12, choices=JOB, default='wuyeyoumin', verbose_name="职业属性")
    grade = models.PositiveIntegerField(default='0', verbose_name="等级")
    desc = models.TextField(max_length=15, verbose_name="个人简介")  # 标准十五字
    email = models.EmailField(max_length=254, verbose_name="邮箱")
    active_level = models.PositiveIntegerField(default=1, verbose_name="活跃度")
    status = models.PositiveIntegerField(default=1, choices=USERACCOUNT_STATUS, verbose_name="账号状态")
    follows = models.PositiveIntegerField(default=0, verbose_name="关注数")
    fans = models.PositiveIntegerField(default=0, verbose_name="粉丝数")
    updated = models.DateTimeField(auto_now=True, verbose_name="更新日期")

    class Meta:
        verbose_name = "用户账户"
        verbose_name_plural = verbose_name
        ordering = ("-date_joined",)

    def __str__(self):
        return self.username

    def all_valid(self):
        return UserAccount.objects.filter(status=1)

    def getValidUser(self, id):
        return UserAccount.objects.filter(id=id, status=1)

    # 活跃度 +1
    def increase_active_level(self):
        self.active_level += 1
        self.save(update_fields=['active_level', 'updated'])

    # 活跃度 -1
    def lower_active_level(self):
        self.active_level -= 1
        self.save(update_fields=['active_level', 'updated'])

    # 关注数 +1
    def increase_follows(self):
        self.follows += 1
        self.save(update_fields=['follows', 'updated'])

    # 关注数 -1
    def lower_follows(self):
        self.follows -= 1
        self.save(update_fields=['follows', 'updated'])

    # 粉丝数 +1
    def increase_fans(self):
        self.fans += 1
        self.save(update_fields=['fans'])

    # 粉丝数 -1
    def lower_fans(self):
        self.fans -= 1
        self.save(update_fields=['fans'])

```

  * #### serializers.py 基本使用(serializers 使用方式比较繁多，也灵活，后续再写文章详细讲解)
```python
import time

from rest_framework import serializers
from rest_framework.validators import UniqueValidator
from django.contrib.auth import get_user_model
from rest_framework_jwt.settings import api_settings

from apps.util import VerifyCodeUtil

User = get_user_model()


# 用户注册序列化 - 用户注册
class UserRegisterSerializer(serializers.ModelSerializer):

    mobile = serializers.CharField(
            label="手机号", required=True, allow_blank=False,
            validators=[UniqueValidator(queryset=User.objects.filter(status=1), message="手机号已注册")])

    code = serializers.CharField(required=True, write_only=True, max_length=4, min_length=4, label="验证码",
                                 error_messages={
                                                "blank": "请输入验证码",
                                                "required": "请输入验证码",
                                                "max_length": "验证码格式错误",
                                                "min_length": "验证码格式错误"
                                                }
                                 )
    username = serializers.CharField(read_only=True, label="用户名")
    # token = serializers.CharField(read_only=True, label="token")
    # username = serializers.CharField(label="用户名", required=False,  # required=True, allow_blank=False,
    #                                  validators=[UniqueValidator(queryset=User.objects.filter(status=1),
    #                                  message="用户名已存在")])
    #
    # password = serializers.CharField(min_length=6, max_length=16, label="密码", required=False,  # required=True,
    #                                  write_only=True, style={'input_type': 'password'},
    #                                  error_messages={"min_length": "密码最少为6位", "max_length": "密码最多为16位"}
    #                                  )

    def validate_code(self, code):
        # 验证码验证
        VerifyCodeUtil.code_validate(serializers, self.initial_data["mobile"], self.initial_data["code"])
        return code

    class Meta:
        model = User
        fields = ("id", "mobile", "code", "username")  # , "token")  # , "password")

    def create(self, validated_data):
        del validated_data["code"]  # 新建用户不需要验证码
        validated_data["username"] = validated_data["mobile"]  # 用户名默认为手机号
        user = super().create(validated_data)
        user.mobile = validated_data['mobile']
        user.username = validated_data['mobile']  # 用户名默认为手机号
        # user.set_password(validated_data["password"])
        user.save()
        # 生成jtw
        # jwt_payload_handler = api_settings.
        # token = 'token'
        # user.token = token
        return user


# 用户基本信息操作验证
class UserInformationDetailSerializer(serializers.ModelSerializer):
    # _href = serializers.HyperlinkedIdentityField(view_name='importers-test-detail')
    class Meta:
        model = User
        fields = ("avatar", "bji", "gender", "job", "desc")

    def update(self, user, validated_data):
        if validated_data["avatar"]:
            user.avatar = validated_data["avatar"]
        if validated_data["bji"]:
            user.bji = validated_data["bji"]
        if validated_data["gender"]:
            user.gender = validated_data["gender"]
        if validated_data["desc"]:
            user.desc = validated_data["desc"]
        if validated_data["job"]:
            user.job = validated_data["job"]
        user.save()
        return user


# 用户敏感信息操作验证
class UserAccountDetailSerializer(serializers.ModelSerializer):

    mobile = serializers.CharField(label="手机号", required=False,
                                   validators=[UniqueValidator(queryset=User.objects.filter(status=1), message="手机号已注册")])

    username = serializers.CharField(label="用户名", required=False,
                                     validators=[UniqueValidator(queryset=User.objects.filter(status=1), message="用户名已存在")])

    password = serializers.CharField(min_length=6, max_length=16, required=False, label="密码",
                                     write_only=True, style={'input_type': 'password'},
                                     error_messages={"min_length": "密码最少为6位", "max_length": "密码最多为16位"}
                                     )

    code = serializers.CharField(required=True, write_only=True, max_length=4, min_length=4, label="验证码",
                                 error_messages={
                                                "blank": "请输入验证码",
                                                "required": "请输入验证码",
                                                "max_length": "验证码格式错误",
                                                "min_length": "验证码格式错误"
                                                }
                                 )

    class Meta:
        model = User
        fields = ("username", "email", "mobile", "password", "code")

    # def validate_mobile(self, mobile):
    #     # 新手机号验证
    #     VerifyCodeUtil.mobile_validate(serializers, mobile)
    #     return mobile

    def validate_code(self, code):
        # 验证码验证
        VerifyCodeUtil.code_validate(serializers, self.instance.mobile, code)
        # del attrs["code"]
        return code

    def update(self, user, validated_data):
        if validated_data.get("mobile", ""):
            user.mobile = validated_data["mobile"]
        if validated_data.get("username", ""):
            user.username = validated_data["username"]
        if validated_data.get("email", ""):
            user.email = validated_data["email"]
        if validated_data.get("password", ""):
            user.set_password(validated_data["password"])
        user.save()
        return user

```

  * #### views.py 基本使用(views 使用方式比较繁多，也灵活，后续再写文章详细讲解)
```python
from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model
from django.db.models import Q

from rest_framework import mixins, permissions
from rest_framework import viewsets
from rest_framework.authentication import SessionAuthentication
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import BasePermission
from rest_framework_jwt.authentication import JSONWebTokenAuthentication

from account.serializers import UserAccountDetailSerializer, SmsSerializer, UserRegisterSerializer, UserInformationDetailSerializer
from util import VerifyCodeUtil

User = get_user_model()


# 自定义用户验证规则 - 登录，用户名密码登录
class ToLogin(ModelBackend):

    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            users = User.objects.filter(Q(username=username) | Q(mobile=username) | Q(email=username)).exclude(status=0)
            # django的后台中密码加密验证调用 check_password(self, raw_password):
            if users:
                for user in users:
                    if user.check_password(password):
                        return user
        except Exception as e:
            return None


# 自定义用户验证规则 - 登录，手机号验证码登录
class MobileToLogin(ModelBackend):
    # username 为手机号码，password 为验证码
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            if len(password) == 4:
                # 验证码验证
                if VerifyCodeUtil.mobile_code_validate(username, password):
                    users = User.objects.filter(mobile=username)
                    if users:  # 该手机号信息存在，返回有效用户信息
                        for user in users:
                            if user.status == 1:
                                return user
                    else:  # 该手机号信息不存在，创建用户信息并返回
                        ur_data = {'mobile': username, 'code': password}
                        ur_i = UserRegisterSerializer(data=ur_data)
                        if ur_i.is_valid():
                            return ur_i.create(ur_i.validated_data)

        except Exception as e:
            return None


# 分页
class BasePagination(PageNumberPagination):

    page_size = 2
    page_size_query_param = 'page_size'
    page_query_param = "page"
    max_page_size = 100


class UserRegisterViewset(mixins.ListModelMixin, mixins.CreateModelMixin, viewsets.GenericViewSet):

    """
    用户注册
    """
    serializer_class = UserRegisterSerializer

    # permission_classes = (permissions.IsAuthenticated, )
    def get_permissions(self):
        if self.action == "list":
            return [permissions.IsAdminUser()]
        elif self.action == "create":
            return []
        return []

    def get_queryset(self):
        return User.objects.filter(status=1).order_by('-date_joined')


# 用户基本信息操作
class UserInformationViewSet(mixins.RetrieveModelMixin, mixins.UpdateModelMixin, viewsets.GenericViewSet):

    serializer_class = UserInformationDetailSerializer
    # permission_classes = (permissions.IsAuthenticated, )
    # 标记需要进行jwt验证
    authentication_classes = (JSONWebTokenAuthentication,)  # , SessionAuthentication)

    # def get_permissions(self):
    #     if self.action == "retrieve":
    #         return [permissions.IsAuthenticated()]
    #     elif self.action == "update":
    #         return [permissions.IsAuthenticated()]
    #     return [p() for p in self.permission_classes]

    # 重写该方法，不管传什么id，都只返回当前用户
    def get_object(self):
        return self.request.user

    # def get_queryset(self):
    #     return User.objects.filter(status=1).order_by('-date_joined')


# 用户敏感信息操作
class UserAccountViewSet(mixins.RetrieveModelMixin, mixins.UpdateModelMixin, viewsets.GenericViewSet):

    serializer_class = UserAccountDetailSerializer
    permission_classes = (permissions.IsAuthenticated, )

    # def get_permissions(self):
    #     if self.action == "list":
    #         return [permissions.IsAdminUser()]
    #     elif self.action == "retrieve":
    #         return [permissions.IsAuthenticated()]
    #     elif self.action == "update":
    #         return [permissions.IsAuthenticated()]
    #     return [permissions.IsAdminUser()]

    # 重写该方法，不管传什么id，都只返回当前用户
    def get_object(self):
        return self.request.user

    # def get_queryset(self):
    #     return User.objects.filter(status=1).order_by('-date_joined')

```

  * #### urls.py 基本使用(urls 管理配置方式，这里只做参考)
```python
#  ####### 赴梦网络
from django.conf.urls import include, url
from django.urls import path
from rest_framework_jwt.views import obtain_jwt_token, refresh_jwt_token, verify_jwt_token
from rest_framework import routers
import xadmin
from account.views import SmsCodeViewSet, UserRegisterViewset, UserInformationViewSet, UserAccountViewSet
from security.views import PrivacyViewset, ProposalViewset
from region.views import UserRegionViewset, RegionViewset

router = routers.DefaultRouter()

# 获取验证码
router.register(r'code', SmsCodeViewSet, base_name='codes')
# 用户注册
router.register(r'register', UserRegisterViewset, base_name='register')
# 用户基本信息操作
router.register(r'userInfo', UserInformationViewSet, base_name='UserInfo')
# 用户敏感信息操作
router.register(r'userAccount', UserAccountViewSet, base_name='UserAccount')

# 社区
router.register(r'region', RegionViewset, base_name='Region')
# 用户与社区
router.register(r'userRegion', UserRegionViewset, base_name='UserRegion')

# 隐私 隐私管理
router.register(r'privacy', PrivacyViewset, base_name='Privacy')
# 建议箱  我的建议
router.register(r'proposal', ProposalViewset, base_name='Proposal')


urlpatterns = [
    # ADMIN URL 后台管理
    # path('admin/', admin.site.urls),
    path("xadmin/", xadmin.site.urls),

    # 后台 api 查看测试
    path("api/", include('rest_framework.urls', namespace='rest_framework')),
    # path("api-token-auth/", views.obtain_auth_token),  # drf 自带的 token 认证

    # jwt token 认证
    path("api-token-auth/", obtain_jwt_token),  # POST 获取令牌  # 登录获取令牌
    path("api-token-refresh/", refresh_jwt_token),  # 刷新令牌 可以“刷新” 未过期的令牌以获得具有更新到期时间的全新令牌
    path("api-token-verify/", verify_jwt_token),  # 验证令牌 在将受保护资源返回给用户之前等待JWT有效的确认

    # 登录
    path("login/", obtain_jwt_token),  # 登录获取令牌

    # API URLS
    # url("", include(router.urls)),

] + router.urls  # API URLS

```

  * #### settings.py 基本使用(settings 配置比较繁多，这里只做参考，后续再写文章详细讲解)
```python
#  ####### 赴梦网络
import os
import sys
import datetime
import platform
from django.utils.translation import ugettext_lazy as _

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 导入资源包
# sys.path.insert(0, os.path.join(BASE_DIR, "apps"))
# sys.path.insert(1, os.path.join(BASE_DIR, "extra_apps"))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/2.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '***************************************************'

# 判断当前操作系统
this_os = 'Windows' not in list(platform.uname())

# SECURITY WARNING: don't run with debug turned on in production!
# 运行模式 DEBUG
DEBUG = this_os

ALLOWED_HOSTS = ['*']


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework.authtoken',
    'corsheaders',

    'extra_apps.xadmin',
    'crispy_forms',
    'reversion',

    'account',
    'base',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',  #
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # 设置浏览器跨域问题
]

ROOT_URLCONF = 'fmwl.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')]
        ,
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'fmwl.wsgi.application'


# Database
# https://docs.djangoproject.com/en/2.1/ref/settings/#databases

# DATABASES = {
# #     'default': {
# #         'ENGINE': 'django.db.backends.sqlite3',
# #         'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
# #     }
# # }
# 使用 mysql 数据库
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'fmwl',
        'USER': 'root',
        'PASSWORD': 'root',
        'HOST': '0-0.life',
        'PORT': '3306',
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
        },
    }
}

# Password validation
# https://docs.djangoproject.com/en/2.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/2.1/topics/i18n/

# LANGUAGE_CODE = 'en-us'
LANGUAGE_CODE = 'zh-hans'  # 语言

LANGUAGES = (
    ('en', _('English')),
    ('zh-hans', _('Chinese')),
)

# TIME_ZONE = 'UTC'
TIME_ZONE = 'Asia/Shanghai'  # 时区

USE_I18N = True

USE_L10N = True

# USE_TZ = True
USE_TZ = False


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/2.1/howto/static-files/

STATIC_URL = '/static/'

# 静态文件 static 集成路径
STATIC_ROOT = r'/home/fmwl/static_data/static/' if this_os else r'C:/Users/static_data/static/'


STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'static'),  # 项目文件夹名称
)

AUTH_USER_MODEL = "account.UserAccount"  # 自定义用户账户模型

# login 自定义登录验证，配置多个时有一个验证通过即可
AUTHENTICATION_BACKENDS = {
     'account.views.ToLogin',
     'account.views.MobileToLogin',
}

# 缓存过期时间
REST_FRAMEWORK_EXTENSIONS = {
    'DEFAULT_CACHE_RESPONSE_TIMEOUT': 60 * 15
}

LOGOUT_REDIRECT_URL = '/'  # 缺省的跳转路径 - 登出后
LOGIN_REDIRECT_URL = '/'  # 缺省的跳转路径 - 登录后


# 跨域
CORS_ORIGIN_ALLOW_ALL = True

CORS_ORIGIN_WHITELIST = (
    "localhost:3000",
)

CORS_ALLOW_METHODS = (
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'OPTIONS'
)

# JWT config
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        # 'rest_framework.authentication.TokenAuthentication',  # 全局认证drf 自带的
        'rest_framework_jwt.authentication.JSONWebTokenAuthentication',  # 全局认证，开源 jwt
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        # 允许的认证方式
        'rest_framework.permissions.IsAuthenticated',  # 已登录
        # 'rest_framework.permissions.DjangoModelPermissionsOrAnonReadOnly'  # 未认证的只读
    )
}

# JWT_AUTH = {  # JWT_AUTH 默认配置
#     # see http://getblimp.github.io/django-rest-framework-jwt/
#     'JWT_ENCODE_HANDLER':
#     'rest_framework_jwt.utils.jwt_encode_handler',
#
#     'JWT_DECODE_HANDLER':
#     'rest_framework_jwt.utils.jwt_decode_handler',
#
#     'JWT_PAYLOAD_HANDLER':
#     'rest_framework_jwt.utils.jwt_payload_handler',
#
#     'JWT_PAYLOAD_GET_USER_ID_HANDLER':
#     'rest_framework_jwt.utils.jwt_get_user_id_from_payload_handler',
#
#     'JWT_RESPONSE_PAYLOAD_HANDLER':
#     'rest_framework_jwt.utils.jwt_response_payload_handler',
#
#     'JWT_SECRET_KEY': SECRET_KEY,
#     'JWT_GET_USER_SECRET_KEY': None,
#     'JWT_PUBLIC_KEY': None,
#     'JWT_PRIVATE_KEY': None,
#     'JWT_ALGORITHM': 'HS256',
#     'JWT_VERIFY': True,
#     'JWT_VERIFY_EXPIRATION': True,
#     'JWT_LEEWAY': 0,
#     'JWT_EXPIRATION_DELTA': datetime.timedelta(seconds=300),
#     'JWT_AUDIENCE': None,
#     'JWT_ISSUER': None,
#
#     'JWT_ALLOW_REFRESH': False,  # 启用令牌刷新功能。发行的令牌rest_framework_jwt.views.obtain_jwt_token将有一个orig_iat字段
#     'JWT_REFRESH_EXPIRATION_DELTA': datetime.timedelta(days=7),
#
#     'JWT_AUTH_HEADER_PREFIX': 'JWT',
#     'JWT_AUTH_COOKIE': None,
#
# }


# 成功获取认证后返回的数据格式
def jwt_response_payload_handler(token, user=None, request=None):
    data = {
        "token": token,
        "id": user.id,
        "username": user.username,
    }
    return data


JWT_AUTH = {
    'JWT_RESPONSE_PAYLOAD_HANDLER': jwt_response_payload_handler,  # 成功获取认证后返回的数据格式
    'JWT_EXPIRATION_DELTA': datetime.timedelta(days=7),  # 验证令牌时所使用的令牌的有效时间
    'JWT_ALLOW_REFRESH': True,  # 启用令牌刷新功能。发行的令牌rest_framework_jwt.views.obtain_jwt_token将有一个orig_iat字段
    'JWT_REFRESH_EXPIRATION_DELTA': datetime.timedelta(days=7),  # 刷新令牌时所使用的旧令牌的有效时间
    'JWT_AUTH_HEADER_PREFIX': 'JWT',
}

```

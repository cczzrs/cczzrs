<!DOCTYPE html>

{# NexT version #}
{% set version = next_env('version') %}

{# Language & Config #}
{% set title = __('title') !== 'title' && __('title') || config.title %}
{% set subtitle = __('subtitle') !== 'subtitle' && __('subtitle') || config.subtitle %}
{% set author = __('author') !== 'author' && __('author') || config.author %}
{% set description = __('description') !== 'description' && __('description') || config.description %}

{% set html_class = 'theme-next ' + theme.scheme %}
{% if theme.motion.enable %}
  {% set html_class = html_class + ' use-motion' %}
{% endif %}

<html class="{{ html_class | lower }}" lang="{{ config.language }}">
<head>
  {{ partial('_partials/head/head.swig', {}, {cache: theme.cache.enable}) }}
  {% include '_partials/head/head-unique.swig' %}
  <title>{% block title %}{% endblock %}</title>
  {% include '_third-party/analytics/index.swig' %}
  {{ partial('_scripts/noscript.swig', {}, {cache: theme.cache.enable}) }}
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ page.lang || page.language || config.language }}">

  {% set container_class = 'container' %}
  {% if theme.sidebar.position %}
    {% set container_class = container_class + ' sidebar-position-' + theme.sidebar.position %}
  {% endif %}

  <div class="{{ container_class }} {% block page_class %}{% endblock %}">
    <div class="headband"></div>

    <header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner">{% include '_partials/header/index.swig' %}</div>
    </header>

    {{ partial('_partials/github-banner.swig', {}, {cache: theme.cache.enable}) }}

    <main id="main" class="main">
      <div class="main-inner">
        <div class="content-wrap">
          {% if theme.scheme === 'Pisces' || theme.scheme === 'Gemini' %}
            {% include '_partials/header/sub-menu.swig' %}
          {% endif %}
          <div id="content" class="content">
            {% block content %}{% endblock %}
          </div>
          {% include '_partials/comments.swig' %}
        </div>
        {% if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {% endif %}
      </div>
    </main>

    <footer id="footer" class="footer">
      <div class="footer-inner">
        {{ partial('_partials/footer.swig', {}, {cache: theme.cache.enable}) }}
        {% include '_third-party/analytics/analytics-with-widget.swig' %}
        {% block footer %}{% endblock %}
      </div>
    </footer>

    {% if theme.back2top.enable and not theme.back2top.sidebar %}
      <div class="back-to-top">
        <i class="fa fa-arrow-up"></i>
        {% if theme.back2top.scrollpercent %}
          <span id="scrollpercent"><span>0</span>%</span>
        {% endif %}
      </div>
    {% endif %}

    {% if theme.needmoreshare2.enable and theme.needmoreshare2.float.enable %}
      <div id="needsharebutton-float">
        <span class="btn">
          <i class="fa fa-share-alt" aria-hidden="true"></i>
        </span>
      </div>
    {% endif %}

    {% if theme.baidushare and theme.baidushare.type === "slide" %}
      <div>
        {% include '_partials/share/baidushare.swig' %}
      </div>
    {% endif %}

    {% if theme.add_this_id %}
      <div>
        {% include '_partials/share/add-this.swig' %}
      </div>
    {% endif %}
  </div>

  {% include '_scripts/vendors.swig' %}
  {% include '_scripts/commons.swig' %}

  {% set scheme_script = '_scripts/schemes/' + theme.scheme | lower + '.swig' %}
  {% include scheme_script %}

  {% block script_extra %}{% endblock %}

  {% include '_scripts/next-boot.swig' %}
  {% include '_scripts/scroll-cookie.swig' %}
  {% include '_scripts/exturl.swig' %}
  {% include '_third-party/quicklink.swig' %}
  {% include '_third-party/comments/index.swig' %}
  {% include '_third-party/search/index.swig' %}
  {% include '_third-party/analytics/lean-analytics.swig' %}
  {% include '_third-party/analytics/firestore.swig' %}
  {% include '_third-party/math/index.swig' %}
  {% include '_third-party/pdf.swig' %}
  {% include '_third-party/mermaid.swig' %}
  {% include '_third-party/baidu-push.swig' %}
  {% include '_third-party/schedule.swig' %}
  {% include '_third-party/needsharebutton.swig' %}
  {% include '_third-party/rating.swig' %}
  {% include '_third-party/pangu.swig' %}
  {% include '_third-party/bookmark.swig' %}
  {% include '_third-party/copy-code.swig' %}
  {% include '_third-party/chatra.swig' %}
  {% include '_third-party/tidio.swig' %}
</body>
<!-- 页面点击小红心
<script type="text/javascript" src="/js/src/love.js"></script> -->
<!-- 调整聊天窗口显示样式 -->
<script type="text/javascript">
  $(function(){
    var intervalId = setInterval(function () {
      var t = $("#daodream-launcher")[0];
      if (t){
        // t.style["bottom"] = "90px";
        var v = $("#daodream-messenger > div");
        for(var i=0;i<v.length;i++){
          $(v[i])[0].style.width="280px";
        }
        // $(".main-inner")[0].style.width="71%";
        // $(".main-inner")[0].style["padding-right"]="38px";
        clearInterval(intervalId);
      }
    }, 1000);
  });
</script>
<!-- dockerhub图标 -->
<script type="text/javascript">
  $(function(){
    var t = $("[class$='fa-dockerhub']")[0];
    if (t){
      t = $(t);
      t.html('<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" class="dicon   " viewBox="0 0 36 26"><path d="M35.2114674,9.90088871 C34.4018592,9.33913616 32.5465072,9.12847895 31.0959592,9.40935523 C30.9272908,8.00497385 30.1514163,6.77614015 28.8020694,5.68774458 L28.0261949,5.12599203 L27.4864561,5.93351132 C26.8117826,6.98679735 26.4744459,8.4613978 26.5756469,9.86577918 C26.6093806,10.3573127 26.778049,11.235051 27.2840541,12.0074608 C26.8117826,12.2883371 25.8335061,12.6394324 24.5516265,12.6394324 L0.16218026,12.6394324 L0.0947129121,12.9203087 C-0.141422805,14.32469 -0.141422805,18.7133819 2.62473845,22.0838972 C4.71622623,24.6468932 7.81972423,25.9459459 11.9014988,25.9459459 C20.7397213,25.9459459 27.2840541,21.6976923 30.3538184,14.0087042 C31.5682306,14.0438138 34.1657235,14.0087042 35.4813368,11.3754892 C35.5150705,11.3052701 35.5825378,11.1648319 35.8186736,10.6381889 L35.9536082,10.3573127 L35.2114674,9.90088871 L35.2114674,9.90088871 Z M19.6602438,0 L15.9495396,0 L15.9495396,3.51095344 L19.6602438,3.51095344 L19.6602438,0 L19.6602438,0 Z M19.6602438,4.21314413 L15.9495396,4.21314413 L15.9495396,7.72409758 L19.6602438,7.72409758 L19.6602438,4.21314413 L19.6602438,4.21314413 Z M15.2748662,4.21314413 L11.564162,4.21314413 L11.564162,7.72409758 L15.2748662,7.72409758 L15.2748662,4.21314413 L15.2748662,4.21314413 Z M10.8894886,4.21314413 L7.17878443,4.21314413 L7.17878443,7.72409758 L10.8894886,7.72409758 L10.8894886,4.21314413 L10.8894886,4.21314413 Z M6.50411095,8.42628826 L2.79340682,8.42628826 L2.79340682,11.9372417 L6.50411095,11.9372417 L6.50411095,8.42628826 L6.50411095,8.42628826 Z M10.8894886,8.42628826 L7.17878443,8.42628826 L7.17878443,11.9372417 L10.8894886,11.9372417 L10.8894886,8.42628826 L10.8894886,8.42628826 Z M15.2748662,8.42628826 L11.564162,8.42628826 L11.564162,11.9372417 L15.2748662,11.9372417 L15.2748662,8.42628826 L15.2748662,8.42628826 Z M19.6602438,8.42628826 L15.9495396,8.42628826 L15.9495396,11.9372417 L19.6602438,11.9372417 L19.6602438,8.42628826 L19.6602438,8.42628826 Z M24.0456214,8.42628826 L20.3349172,8.42628826 L20.3349172,11.9372417 L24.0456214,11.9372417 L24.0456214,8.42628826 L24.0456214,8.42628826 Z"></path></svg>');
      t[0].style.fill = "#555"
    }
  });
</script>

</html>

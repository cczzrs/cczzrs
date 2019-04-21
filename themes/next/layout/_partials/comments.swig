{% if page.comments %}

  {% if theme.facebook_sdk.enable and theme.facebook_comments_plugin.enable %}
    <div class="comments" id="comments">
      <div class="fb-comments"
           data-href="{{ page.permalink }}"
           data-numposts="{{ theme.facebook_comments_plugin.num_of_posts }}"
           data-width="{{ theme.facebook_comments_plugin.width }}"
           data-colorscheme="{{ theme.facebook_comments_plugin.scheme }}">
      </div>
    </div>

  {% elif theme.vkontakte_api.enable and theme.vkontakte_api.comments %}
    <div class="comments" id="comments">
      <div id="vk_comments"></div>
    </div>

  {% elif theme.disqus.enable or (theme.disqusjs.enable and theme.disqusjs.apikey and theme.disqusjs.shortname) %}
    <div class="comments" id="comments">
      <div id="disqus_thread">
        <noscript>{#
        #}Please enable JavaScript to view the comments powered by Disqus.{#
      #}</noscript>
      </div>
    </div>

  {% elif theme.livere_uid %}
    <div class="comments" id="comments">
      <div id="lv-container" data-id="city" data-uid="{{ theme.livere_uid }}"></div>
    </div>

  {% elif theme.changyan.enable and theme.changyan.appid and theme.changyan.appkey %}
    <div class="comments" id="comments">
      <div id="SOHUCS"></div>
    </div>

  {% elif theme.gitment.enable %}
    <div class="comments" id="comments">
      {% if theme.gitment.lazy %}
        <div onclick="showGitment()" id="gitment-display-button">{{ __('gitmentbutton') }}</div>
        <div id="gitment-container" style="display: none"></div>
      {% else %}
        <div id="gitment-container"></div>
      {% endif %}
    </div>

  {% elif theme.valine.enable and theme.valine.appid and theme.valine.appkey %}
    <div class="comments" id="comments"></div>
      {% if (theme.valine and theme.valine.enable)%}
      <script src="//cdn1.lncld.net/static/js/3.0.4/av-min.js"></script>
      <script src="//cdn.jsdelivr.net/npm/valine@1.1.6/dist/Valine.min.js"></script>
      <script>
          new Valine({
              av: AV,
              el: '.comments',
              notify: true, // 邮件提醒 v1.1.4新增，下一步中有具体的邮箱设置
              verify: true,
              app_id: '{{ theme.valine.appId }}',
              app_key: '{{ theme.valine.appKey }}',
              placeholder: 'ヾﾉ≧∀≦)o来啊，快活啊!'
          });
      </script>
      {% endif %}
  {% elif theme.gitalk.enable %}
    <div class="comments" id="gitalk-container">
    </div>

  {% endif %}

{% endif %}

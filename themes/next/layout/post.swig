{% extends '_layout.swig' %}
{% import '_macro/post.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}


{% block title %}{{ page.title }} | {{ config.title }}{% endblock %}

{% block page_class %}page-post-detail{% endblock %}


{% block content %}

  <div id="posts" class="posts-expand">
    {{ post_template.render(page) }}

    <div class="post-spread">
      {% if theme.jiathis %}
        {% include '_partials/share/jiathis.swig' %}
      {% elseif theme.baidushare %}
        {% include '_partials/share/baidushare.swig' %}
      {% elseif theme.add_this_id %}
        {% include '_partials/share/add-this.swig' %}
      {% elseif theme.duoshuo_shortname and theme.duoshuo_share %}
        {% include '_partials/share/duoshuo_share.swig' %}
      {% endif %}
    </div>
  </div>

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(true) }}
{% endblock %}


{% block script_extra %}
  {% include '_scripts/pages/post-details.swig' %}
{% endblock %}

{# LeanCould PageView #}
{% if theme.leancloud_visitors.enable %}
   <span id="{{ url_for(post.path) }}" class="leancloud_visitors" data-flag-title="{{ post.title }}">
     &nbsp; | &nbsp;
     <span class="post-meta-item-icon">
       <i class="fa fa-eye"></i>
     </span>
     <span class="post-meta-item-text">{{__('post.visitors')}} </span>
     <span class="leancloud-visitors-count"></span>
    </span>
{% endif %}


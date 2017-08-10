<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love">
    <i class="fa fa-{{ theme.authoricon }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ config.author }}</span>
</div>
<div>
<script async src="https://dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js"></script>
<span id="site-visit" title="本站访问量"><i class="fa fa-user" aria-hidden="true"></i>&nbsp<span id="busuanzi_value_site_pv"></span></span>&nbsp | &nbsp
<span id="page-visit"  title="本站到访数"><i class="fa fa-eye animated infinite pulse" aria-hidden="true"></i>&nbsp<span id="busuanzi_value_site_uv"></span>
</div>

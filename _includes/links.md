  {% for post in site.posts %}
  {% unless post.search == "exclude" %}
  {% unless post.url contains ".css" %}
  {% unless post.url contains ".js" %}
	{% if post.title != nil %}
	   [{{post.title}}]: {{site.url}}{{post.url}}
	{% endif %}
  {% endunless %}
  {% endunless %}
  {% endunless %}
  {% endfor %}

  {% for page in site.pages %}
  {% unless page.search == "exclude" %}
  {% unless page.url contains ".css" %}
  {% unless page.url contains ".js" %}
    {% if page.title != nil %}
       [{{page.title}}]: {{site.url}}{{page.url}}
	{% endif %}
  {% endunless %}
  {% endunless %}
  {% endunless %}
  {% endfor %}
clean-posts:
	find ./_posts -type f -exec rm {} \;

import-posts:
	cp ~/proyectos/aprox/jekyll/_posts/*  ~/proyectos/aprox.github.io/_posts/

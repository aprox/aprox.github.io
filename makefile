PROJECTS_DIR=$(HOME)/proyectos
ARPOX_DIR=$(PROJECTS_DIR)/aprox
APROX_HEROKU_DIR=$(PROJECTS_DIR)/aprox2

jekyll-export: import-posts
	bundle exec jekyll build -d $(APROX_HEROKU_DIR)/_site

import-posts:
	make -C $(ARPOX_DIR) publish-org

clean-posts:
	find ./_posts -type f -exec rm {} \;


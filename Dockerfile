FROM node:12.20.0 as node
FROM ruby:2.7.2
ARG RAILS_ENV
ARG NODE_ENV
ARG RAILS_MASTER_KEY
ARG precompileassets
ENV LANG C.UTF-8

RUN apt-get update
RUN apt-get install -y graphviz

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn
RUN ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY package.json yarn.lock /app/
RUN yarn install

COPY . /app

COPY asset_precompile.sh /usr/bin/
RUN chmod +x /usr/bin/asset_precompile.sh
RUN asset_precompile.sh $precompileassets

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]

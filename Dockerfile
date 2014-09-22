FROM centurylink/ruby-base:2.1.2

EXPOSE 9292

ADD . /var/app/kubernetes-adapter
WORKDIR /var/app/kubernetes-adapter
RUN bundle install

CMD ["rackup", "-E production"]

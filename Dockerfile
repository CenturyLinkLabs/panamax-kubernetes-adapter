FROM centurylink/ruby-base:2.1.2

ADD . /var/app/kubernetes-adapter
WORKDIR /var/app/kubernetes-adapter
RUN bundle install

CMD ["ruby", "/var/app/kubernetes-adapter/kubernetes.rb"]

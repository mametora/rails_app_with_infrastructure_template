module SitemapGeneratorConfig
  class Adapter
    def initialize(bucket, options = {})
      @bucket = bucket
      @resource_options = options[:resource_options] || {}
      @upload_options = options[:upload_options] || {}
    end

    def write(loc, data)
      SitemapGenerator::FileAdapter.new.write(loc, data)
      resource.bucket(@bucket).object(loc.path_in_public).with_options(@upload_options) do |obj|
        obj.upload_file(
          loc.path,
          content_type: loc[:compress] ? 'application/x-gzip' : 'application/xml'
        )
      end
    end

    private

    def resource
      @resource ||= Aws::S3::Resource.new(@resource_options)
    end
  end
end

SitemapGenerator::Sitemap.default_host = if Rails.env.production?
                                           "https://#{ENV['WEB_HOST']}"
                                         else
                                           "http://www.example.com"
                                         end

Rails.application.config_for(:storage).yield_self do |conf|
  resource_options = {
    force_path_style: conf['force_path_style'],
  }
  resource_options['endpoint'] = conf['endpoint'] if conf['endpoint']
  SitemapGenerator::Sitemap.adapter = SitemapGeneratorConfig::Adapter.new(
    conf['bucket'],
    resource_options: resource_options,
    upload_options: {
      acl: 'private',
      cache_control: 'private, max-age=0, no-cache',
    }
  )
end

SitemapGenerator::Sitemap.create do
  add '/', changefreq: 'daily'
end

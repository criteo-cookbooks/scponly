#
# Matchers for chefspec 3
#
#

if defined?(ChefSpec)
  def create_scponly_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:scponly_user, :create, resource_name)
  end

  def delete_scponly_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:scponly_user, :delete, resource_name)
  end
end

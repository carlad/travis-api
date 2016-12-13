module Travis::API::V3
  class Queries::KeyPair < Query
    params :description, :value, prefix: :key_pair

    def create(repository)
      raise DuplicateResource if repository.key_pair
      Models::KeyPair.new(key_pair_params.merge(repository_id: repository.id)).tap do |key_pair|
        handle_errors(key_pair) unless key_pair.valid?
        key_pair.sync_once(repository, :settings)
      end
    end

    private

    def handle_errors(key_pair)
      value = key_pair.errors[:value]
      raise UnprocessableEntity if value.include?(:invalid_pem)
      raise WrongParams         if value.include?(:missing_attr)
    end
  end
end

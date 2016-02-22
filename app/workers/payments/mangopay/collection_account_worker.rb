module Payments
  module Mangopay
    class CollectionAccountWorker
      include Sidekiq::Worker

      def perform(mangopay_collection_account_id, collection_account_data)
        begin
          init_log(mangopay_collection_account_id)

          @mca = MangopayCollectionAccount.find_by_id(mangopay_collection_account_id)
          return unless @mca.present?

          collection_account_data.symbolize_keys!
          account = create_user(collection_account_data)
          save_collection_account(account, collection_account_data)
        rescue MangoPay::ResponseError => e
          save_account_error(e.message)
        rescue Exception => e
          raise e.exception, e.message
        end
      end

      private

      def init_log(mangopay_collection_account_id)
        str = 'Payments::Mangopay::CollectionAccountWorker on mangopay_collection_account_id: '
        str += mangopay_collection_account_id.to_s
        Rails.logger.info(str)
      end

      def save_collection_account(account, coll_acc_data)
        wallet = create_wallet(account['Id'])
        bank_account = create_bank_account(account['Id'], coll_acc_data)
        @mca.assign_attributes(coll_acc_data)
        @mca.update_attributes(mangopay_user_id: account['Id'], wallet_id: wallet['Id'],
          bank_account_id: bank_account['Id'], expecting_mangopay_response: false,
          status: MangopayCollectionAccount.statuses[:accepted], mangopay_persisted: true,
          active: true)
      end

      def save_account_error(e)
        status = MangopayCollectionAccount.statuses[:rejected]
        status = MangopayCollectionAccount.statuses[:error_updating] if @mca.mangopay_persisted
        @mca.assign_attributes(error_message: e.to_s, expecting_mangopay_response: false,
          status: status)
        @mca.save(validate: false)
      end

      def create_user(coll_acc_data)
        return create_person_user(coll_acc_data) if coll_acc_data[:legal_person_type] == 'PERSON'
        create_non_person_user(coll_acc_data)
      end

      def create_person_user(coll_acc_data)
        user_data = person_user_data_for_mangopay(coll_acc_data)
        return MangoPay::NaturalUser.create(user_data) unless @mca.mangopay_persisted
        MangoPay::NaturalUser.update(@mca.mangopay_user_id, user_data)
      end

      def person_user_data_for_mangopay(coll_acc_data)
        { firstName: coll_acc_data[:first_name], lastName: coll_acc_data[:last_name],
          birthday: coll_acc_data[:date_of_birth].try(:to_time).to_i, nationality: coll_acc_data[:nationality],
          countryOfResidence: coll_acc_data[:country_of_residence], email: coll_acc_data[:email] }
      end

      def create_non_person_user(coll_acc_data)
        user_data = non_person_data_for_mangopay(coll_acc_data)
        return MangoPay::LegalUser.create(user_data) unless @mca.mangopay_persisted
        MangoPay::LegalUser.update(@mca.mangopay_user_id, user_data)
      end

      def non_person_data_for_mangopay(coll_acc_data)
        {
          legalPersonType: coll_acc_data[:legal_person_type],
          legalRepresentativeEmail: coll_acc_data[:email],
          legalRepresentativeBirthday: coll_acc_data[:date_of_birth].try(:to_time).to_i,
          legalRepresentativeCountryOfResidence: coll_acc_data[:country_of_residence],
          legalRepresentativeFirstName: coll_acc_data[:first_name],
          legalRepresentativeLastName: coll_acc_data[:last_name],
          legalRepresentativeNationality: coll_acc_data[:nationality],
          email: coll_acc_data[:business_email],
          name: coll_acc_data[:business_name]
        }
      end

      def create_wallet(mangopay_user_id)
        MangoPay::Wallet.create(
          owners: [mangopay_user_id], currency: 'EUR', description: 'Seller wallet')
      end

      def create_bank_account(mangopay_user_id, coll_acc_data)
        base_data = {
          ownerName: "#{coll_acc_data[:first_name]} #{coll_acc_data[:last_name]}",
          ownerAddress: coll_acc_data[:address], Type: coll_acc_data[:bank_type] }
        send("add_#{coll_acc_data[:bank_type].downcase}_data!", base_data, coll_acc_data)
        return MangoPay::BankAccount.create(mangopay_user_id, base_data) unless
          base_data[:Type].nil?
        # If the Type is nil, it's because there is no sufficient data to create a new bank account
        # (mangopay does not allow to update a bank account...)
        base_data['Id'] = @mca.bank_account_id
        base_data
      end

      def add_iban_data!(base_data, collection_data)
        base_data[:Type] = nil if @mca.mangopay_persisted && collection_data[:iban].nil?
        base_data[:IBAN] = collection_data[:iban]
        base_data[:BIC] = collection_data[:bic]
      end

      def add_gb_data!(base_data, collection_data)
        base_data[:Type] = nil if @mca.mangopay_persisted && collection_data[:account_number].nil?
        base_data[:AccountNumber] = collection_data[:account_number]
        base_data[:SortCode] = collection_data[:sort_code]
      end

      def add_ca_data!(base_data, collection_data)
        base_data[:Type] = nil if @mca.mangopay_persisted && collection_data[:account_number].nil?
        base_data[:AccountNumber] = collection_data[:account_number]
        base_data[:InstitutionNumber] = collection_data[:institution_number]
        base_data[:BankName] = collection_data[:bank_name]
        base_data[:BranchCode] = collection_data[:branch_code]
      end

      def add_other_data!(base_data, collection_data)
        base_data[:Type] = nil if @mca.mangopay_persisted && collection_data[:account_number].nil?
        base_data[:AccountNumber] = collection_data[:account_number]
        base_data[:Country] = collection_data[:bank_country]
        base_data[:BIC] = collection_data[:bic]
        base_data[:AccountNumber] = collection_data[:account_number]
      end
    end
  end
end

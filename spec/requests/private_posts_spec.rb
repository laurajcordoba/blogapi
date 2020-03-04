require "rails_helper"

RSpec.describe "Posts with Authentication", type: :request do
  let!(:user_post) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:post) { create(:post, user_id: user_post.id) }
  let!(:other_user_post) { create(:post, user_id: other_user.id, published: true) }
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user_post.auth_token}" } }
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }
  let!(:create_params) { { "post" => {"title" => "Title", "content" => "Content", "published" => true } } }
  let!(:update_params) { { "post" => {"title" => "Title", "content" => "Content", "published" => true } } }

  # Authorization: Bearer xxxxxxx
  describe "GET /posts{id}" do
    context "with valid auth" do
      context "when requesting other's author post" do
        context "when post is public" do
          before { get "/posts/#{other_user_post.id}", headers: auth_headers }
          context "payload" do
            subject { payload }
            it { is_expected.to include(:id) }
          end

          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end
        context "when post is draft" do
          before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }
          context "payload" do
            subject { payload }
            it { is_expected.to include(:error) }
          end

          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:not_found) }
          end
        end
      end

      context "when requesting user's post" do
      end
    end
  end

  describe "POST /posts" do
    # Con autentication -> create
    before { post "/posts/", params: create_params, headers: auth_headers}
    context "with valid auth" do
      context "payload" do
        subject { payload }
        xit { is_expected.to include(:id, :title, :content, :published, :author) }
      end

      context "response" do
        subject { response }
        xit { is_expected.to have_http_status(:created) }
      end
    end
    # Sin autentication -> !create -> 401 or unauthorize
    context "without auth" do
      before { post "/posts/", params: create_params}
      context "payload" do
        subject { payload }
        xit { is_expected.to include(:error) }
      end

      context "response" do
        subject { response }
        xit { is_expected.to have_http_status(:unauthorize) }
      end
    end

  end

  describe "PUT /posts" do
    # Con autentication
      # actualizar un Post nuestro
      # !actualizar un Post de otro -> 401 or unauthorize
    # Sin autentication -> !actualizar -> 401 or unauthorize
    # Con autentication -> create
    context "with valid auth" do
      context "when updating Uses's post" do
        before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }
        context "payload" do
          subject { payload }
          it { is_expected.to include(:id, :title, :content, :published, :author) }
          it { expect(payload[:id]).to eq(user_post.id) }
        end

        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:ok) }
        end
      end

      context "when updating Uses's post" do
        before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }
        context "payload" do
          subject { payload }
          it { is_expected.to include(:error) }
        end

        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
        end
      end
    end
  end

  private
  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end

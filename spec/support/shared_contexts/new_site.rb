# frozen_string_literal: true

RSpec.shared_context "with a new site" do
  def b(type, *other)
    node = {
      "type" => type,
    }

    param = other.shift

    if param.is_a?(Hash)
      node.merge!(param)
      param = other.shift
    end

    node["children"] = param if param.is_a?(Array)

    node["value"] = param if param.is_a?(String)

    node.stringify_keys
  end

  let(:account_client) do
    generate_account_client!
  end

  let(:site) do
    created_site = account_client.sites.create(
      name: "Integration new test site",
    )

    @persistent_test_site_id = created_site[:id] if persistent_test_account?
    created_site
  end

  let(:client) do
    Dato::Site::Client.new(
      site_api_token(site),
      base_url: ENV.fetch("SITE_API_BASE_URL"),
    )
  end

  let(:item_type) do
    client.item_types.create(
      name: "Article",
      singleton: false,
      modular_block: false,
      sortable: false,
      tree: false,
      draft_mode_active: false,
      api_key: "article",
      ordering_direction: nil,
      ordering_field: nil,
      all_locales_required: true,
      title_field: nil,
    )
  end

  let(:author_type) do
    client.item_types.create(
      name: "Author",
      singleton: false,
      modular_block: false,
      sortable: false,
      tree: false,
      draft_mode_active: false,
      api_key: "author",
      ordering_direction: nil,
      ordering_field: nil,
      all_locales_required: true,
      title_field: nil,
    )
  end

  let(:author_field) do
    client.fields.create(
      author_type[:id],
      api_key: "name",
      field_type: "string",
      label: "Name",
      localized: false,
      hint: "",
      validators: { required: {} },
    )
  end

  let(:block_type) do
    client.item_types.create(
      name: "Block",
      singleton: false,
      modular_block: true,
      sortable: false,
      tree: false,
      draft_mode_active: false,
      api_key: "block",
      ordering_direction: nil,
      ordering_field: nil,
      all_locales_required: true,
      title_field: nil,
    )
  end

  let(:block_field) do
    client.fields.create(
      block_type[:id],
      api_key: "title",
      field_type: "string",
      label: "Title",
      localized: false,
      hint: "",
      validators: { required: {} },
    )
  end

  let(:structured_text_field) do
    client.fields.create(
      item_type[:id],
      api_key: "content",
      field_type: "structured_text",
      label: "Content",
      localized: false,
      hint: "",
      validators: {
        structured_text_blocks: { item_types: [block_type[:id]] },
        structured_text_links: { item_types: [author_type[:id]] },
      },
    )
  end

  let(:text_field) do
    client.fields.create(
      item_type[:id],
      api_key: "title",
      field_type: "string",
      label: "Title",
      localized: true,
      hint: "",
      validators: { required: {} },
    )
  end

  let(:slug_field) do
    client.fields.create(
      item_type[:id],
      api_key: "slug",
      field_type: "slug",
      label: "Slug",
      localized: false,
      hint: "",
      validators: {
        required: {},
        slug_title_field: {
          title_field_id: text_field[:id].to_s,
        },
      },
    )
  end

  let(:image_field) do
    client.fields.create(
      item_type[:id],
      api_key: "image",
      field_type: "file",
      label: "Image",
      localized: false,
      hint: "",
      validators: {
        required: {},
        extension: {
          predefined_list: "image",
        },
      },
    )
  end

  let(:file_field) do
    client.fields.create(
      item_type[:id],
      api_key: "file",
      field_type: "file",
      label: "File",
      localized: false,
      hint: "",
      validators: { required: {} },
    )
  end

  let(:image_id) do
    client.upload_image(
      "https://www.datocms-assets.com/205/1549027974-logo.png",
      default_field_metadata: {
        alt: {
          en: "My first post",
          it: "Il mio primo post",
        },
        title: {
          en: "First post",
          it: "Primo post",
        },
        custom_data: {
          en: {},
          it: {},
        },
        focal_point: {
          x: 0.1,
          y: 0.1,
        },
      },
    )[:upload_id]
  end
  let(:file_id) { client.upload_file("./spec/fixtures/file.txt")[:upload_id] }

  let(:author) do
    client.items.create(
      item_type: author_type[:id],
      author_field[:api_key] => "Mark Smith",
    )
  end

  let(:item) do
    client.items.create(
      item_type: item_type[:id],
      text_field[:api_key] => {
        en: "First post",
        it: "Primo post",
      },
      slug_field[:api_key] => "first-post",
      image_field[:api_key] => {
        upload_id: image_id,
      },
      structured_text_field[:api_key] => {
        schema: "dast",
        document: b("root", [
                      b("heading", { level: 1 }, [b("span", "This is the title!")]),
                      b("paragraph", [
                          b("span", "And "),
                          b("span", { marks: ["strong"] }, "this"),
                          b("span", " is an "),
                          b("itemLink", { item: author[:id] }, [b("span", "author")]),
                        ]),
                      b("paragraph", [b("inlineItem", { item: author[:id] })]),
                      b("block", {
                          item: Dato::Utils::BuildModularBlock.build({
                                                                       item_type: block_type[:id],
                                                                       block_field[:api_key] => "Foo",
                                                                     }),
                        }),
                    ]),
      },
      file_field[:api_key] => {
        upload_id: file_id,
        alt: "My first file",
        title: "My first file",
        custom_data: {},
      },
    )
  end

  before do
    site
    client.site.activate_non_localized_focal_points if persistent_test_account?

    site_attributes = client.site.find
    site_attributes.delete(:theme)

    client.site.update(
      site_attributes.merge(
        locales: %w[en it],
      ),
    )

    client.items.publish(
      item[:id],
      content_in_locales: %w[en it],
      non_localized_content: true,
    )
  end

  after do
    if @persistent_test_site_id
      begin
        account_client.sites.destroy(@persistent_test_site_id)
      rescue StandardError
        warn "Failed to clean up DatoCMS test project #{@persistent_test_site_id}"
        raise
      end
    end
  end
end

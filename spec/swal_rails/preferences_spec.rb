# frozen_string_literal: true

RSpec.describe SwalRails::Preferences do
  let(:owner) { Object.new }

  describe ".suppress guards" do
    before { allow(described_class).to receive(:enabled?).and_return(true) }

    it "ignores an oversized key without touching the DB" do
      expect(SwalRails::DismissedAlert).not_to receive(:exists?)
      expect(SwalRails::DismissedAlert).not_to receive(:create_or_find_by!)
      described_class.suppress(owner, "x" * (described_class::MAX_KEY_LENGTH + 1))
    end

    it "ignores a blank key without touching the DB" do
      expect(SwalRails::DismissedAlert).not_to receive(:create_or_find_by!)
      described_class.suppress(owner, "")
    end

    it "does not create new keys beyond the per-owner cap" do
      allow(SwalRails::DismissedAlert).to receive(:exists?).and_return(false)
      relation = instance_double("ActiveRecord::Relation", count: described_class::MAX_KEYS_PER_OWNER)
      allow(SwalRails::DismissedAlert).to receive(:where).with(owner: owner).and_return(relation)

      expect(SwalRails::DismissedAlert).not_to receive(:create_or_find_by!)
      described_class.suppress(owner, "new.key")
    end

    it "re-suppressing an existing key is a no-op that skips the cap check" do
      allow(SwalRails::DismissedAlert).to receive(:exists?).and_return(true)

      expect(SwalRails::DismissedAlert).not_to receive(:where)
      expect(SwalRails::DismissedAlert).not_to receive(:create_or_find_by!)
      described_class.suppress(owner, "already.muted")
    end

    it "creates a new key when under the cap" do
      allow(SwalRails::DismissedAlert).to receive(:exists?).and_return(false)
      relation = instance_double("ActiveRecord::Relation", count: 0)
      allow(SwalRails::DismissedAlert).to receive(:where).with(owner: owner).and_return(relation)

      expect(SwalRails::DismissedAlert).to receive(:create_or_find_by!).with(owner: owner, key: "posts.saved")
      described_class.suppress(owner, "posts.saved")
    end
  end

  describe ".suppress when disabled" do
    it "no-ops without resolving the DB at all" do
      allow(described_class).to receive(:enabled?).and_return(false)
      expect(SwalRails::DismissedAlert).not_to receive(:exists?)
      expect(described_class.suppress(owner, "k")).to be_nil
    end
  end
end

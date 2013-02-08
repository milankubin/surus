require 'spec_helper'
require 'oj'
ActiveRecord::Base.include_root_in_json = false

describe 'json' do
  describe 'find_json' do
    context 'with only id parameter' do
      it 'is entire row as json' do
        user = FactoryGirl.create :user
        to_json = Oj.load user.to_json
        find_json = Oj.load User.find_json(user.id)
        expect(find_json).to eq(to_json)
      end
    end

    context 'with columns parameter' do
      it 'is selected row columns as json' do
        user = FactoryGirl.create :user
        to_json = Oj.load user.to_json only: [:id, :name]
        find_json = Oj.load User.find_json(user.id, columns: [:id, :name])
        expect(find_json).to eq(to_json)
      end
    end

    context 'with includes option' do
      it 'includes entire belongs_to object' do
        post = FactoryGirl.create :post
        to_json = Oj.load post.to_json(include: :author)
        find_json = Oj.load Post.find_json(post.id, include: :author)
        expect(find_json).to eq(to_json)
      end

      it 'includes multiple entire belongs_to objects' do
        post = FactoryGirl.create :post
        to_json = Oj.load post.to_json(include: [:author, :forum])
        find_json = Oj.load Post.find_json(post.id, include: [:author, :forum])
        expect(find_json).to eq(to_json)
      end

      it 'includes only selected columns of belongs_to object' do
        post = FactoryGirl.create :post
        to_json = Oj.load post.to_json(include: {author: {only: [:id, :name]}})
        find_json = Oj.load Post.find_json(post.id, include: {author: {columns: [:id, :name]}})
        expect(find_json).to eq(to_json)
      end

      it 'includes entire has_many association' do
        user = FactoryGirl.create :user
        posts = FactoryGirl.create_list :post, 2, author: user
        user.reload
        to_json = Oj.load user.to_json(include: :posts)
        find_json = Oj.load User.find_json(user.id, include: :posts)
        expect(find_json).to eq(to_json)
      end

      it 'includes only select columns of has_many association' do
        user = FactoryGirl.create :user
        posts = FactoryGirl.create_list :post, 2, author: user
        user.reload
        to_json = Oj.load user.to_json(include: {posts: {only: [:id, :subject]}})
        find_json = Oj.load User.find_json(user.id, include: {posts: {columns: [:id, :subject]}})
        expect(find_json).to eq(to_json)
      end

      it 'includes nested associations' do
        user = FactoryGirl.create :user
        post = FactoryGirl.create :post, author: user
        user.reload
        to_json = Oj.load user.to_json(include: {posts: {include: :forum}})
        find_json = Oj.load User.find_json(user.id, include: {posts: {include: :forum}})
        expect(find_json).to eq(to_json)
      end

      it 'includes nested associations with columns' do
        user = FactoryGirl.create :user
        post = FactoryGirl.create :post, author: user
        user.reload
        to_json = Oj.load user.to_json(include: {posts: {only: [:id], include: :forum}})
        find_json = Oj.load User.find_json(user.id, include: {posts: {columns: [:id], include: :forum}})
        expect(find_json).to eq(to_json)
      end
    end
  end
end

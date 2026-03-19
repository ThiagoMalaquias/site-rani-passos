class Course::Duplicate
  def initialize(course)
    @course = course
  end

  def call
    ActiveRecord::Base.transaction do
      new_course = create_new_course_from_current_course
      new_course.image.attach(@course.image.blob) if @course.image.attached?
      new_course.banner.attach(@course.banner.blob) if @course.banner.attached?
      new_course.image_mobile.attach(@course.image_mobile.blob) if @course.image_mobile.attached?
      new_course.course_categories.create(@course.course_categories.map { |category| { category_id: category.category_id } })
      new_course.course_discounts.create(@course.course_discounts.map { |discount| { discount_id: discount.discount_id } })
      duplicate_matters(new_course)
    end
  end

  private

  def create_new_course_from_current_course
    attrs = @course.attributes.except("id", "slug", "created_at", "updated_at")
    title = "#{@course.title} - #{Time.zone.now.strftime('%d-%m-%Y')}"
    Course.create(attrs.merge(title: title))
  end

  def duplicate_matters(new_course)
    @course.matters.each do |matter|
      new_matter = duplicate_record(new_course.matters, matter)
      duplicate_capsules(new_matter, matter)
    end
  end

  def duplicate_capsules(new_matter, other_matter)
    other_matter.capsules.each do |capsule|
      attrs = capsule.attributes.except("id", "course_id", "created_at", "updated_at")
      new_capsule = new_matter.capsules.create(attrs.merge(course_id: new_matter.course_id))
      duplicate_lessons(new_capsule, capsule)
    end
  end

  def duplicate_lessons(new_capsule, other_capsule)
    other_capsule.lessons.each do |lesson|
      new_lesson = duplicate_record(new_capsule.lessons, lesson)
      duplicate_lesson_content(new_lesson, lesson)
      duplicate_lesson_completed_pdfs(new_lesson, lesson)
      duplicate_lesson_summarized_pdfs(new_lesson, lesson)
      duplicate_lesson_mind_maps(new_lesson, lesson)
      duplicate_lesson_womb_component_lectures(new_lesson, lesson)
      duplicate_lesson_lecture_videos(new_lesson, lesson)
    end
  end

  def duplicate_lesson_content(new_lesson, lesson)
    lesson.lesson_content.each do |content|
      lesson_content = duplicate_record(new_lesson.lesson_content, content)
      lesson_content.midia.attach(content.midia.blob)
    end
  end

  def duplicate_lesson_completed_pdfs(new_lesson, lesson)
    lesson.lesson_completed_pdfs.each do |completed|
      completed_pdf = duplicate_record(new_lesson.lesson_completed_pdfs, completed)
      completed_pdf.midia.attach(completed.midia.blob)
    end
  end

  def duplicate_lesson_summarized_pdfs(new_lesson, lesson)
    lesson.lesson_summarized_pdfs.each do |summarized|
      summarized_pdf = duplicate_record(new_lesson.lesson_summarized_pdfs, summarized)
      summarized_pdf.midia.attach(summarized.midia.blob)
    end
  end

  def duplicate_lesson_mind_maps(new_lesson, lesson)
    lesson.lesson_mind_maps.each do |mind|
      mind_map = duplicate_record(new_lesson.lesson_mind_maps, mind)
      mind_map.midia.attach(mind.midia.blob)
    end
  end

  def duplicate_lesson_womb_component_lectures(new_lesson, lesson)
    lesson.lesson_womb_component_lectures.each do |womb_component_lecture|
      duplicate_record(new_lesson.lesson_womb_component_lectures, womb_component_lecture)
    end
  end

  def duplicate_lesson_lecture_videos(new_lesson, lesson)
    lesson.lesson_lecture_videos.each do |lecture_video|
      duplicate_record(new_lesson.lesson_lecture_videos, lecture_video)
    end
  end

  def duplicate_record(collection, record)
    attrs = record.attributes.except("id", "created_at", "updated_at")
    collection.create(attrs)
  end
end

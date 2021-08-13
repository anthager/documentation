const handleResults = (data) => {
  const result = document.getElementById("result");
  console.log(data);

  result.innerHTML = "";

  const hits = data;
  if (hits && hits.length > 0) {
    document.getElementById("hits").innerHTML = `${hits.length} hit(s)`;

    const unorderedList = document.createElement("ul");
    unorderedList.className = "media-list";
    result.appendChild(unorderedList);

    const baseURL = {
      open: "http://docs.vespa.ai",
      cloud: "https://cloud.vespa.ai",
      blog: "https://blog.vespa.ai",
      vespaai: "https://vespa.ai",
      vespaapps: "https://github.com/vespa-engine/sample-apps/tree/master",
    };

    const sourceName = {
      open: "Documentation",
      cloud: "Cloud",
      blog: "Blog",
      vespaai: "Vespa.ai",
      vespaapps: "Vespa Sample Apps",
    };

    const highlightWeight = 10;

    console.dir(hits);

    hits.forEach(
      ({
        fields: {
          namespace,
          path,
          content,
          title,
          summaryfeatures,
        },
      }) => {
        const modifiedURL = baseURL[namespace] + path;

        const modifiedContent = (
          content
        )
          .replaceAll("<sep />", " ... ")
          .replaceAll("<hi>", "<mark>")
          .replaceAll("</hi>", "</mark>");

        const modifiedTitle =
          title == "null"
            ? "No title"
            : title
                .replaceAll("<hi>", "<mark>")
                .replaceAll("</hi>", "</mark>");

        const listItem = document.createElement("li");
        listItem.className = "media";

        const header = document.createElement("h4");
        header.innerHTML = `<a href="${modifiedURL}">${modifiedTitle}</a>`;

        const paragraph = document.createElement("p");
        paragraph.innerHTML = modifiedContent;
        const paragraphBreak = document.createElement("br");
        paragraph.appendChild(paragraphBreak);
        const paragraphSmall = document.createElement("small");
        paragraphSmall.className = "text-success";
        paragraphSmall.innerHTML = `${sourceName[namespace]}: ${path}`;
        paragraph.appendChild(paragraphSmall);

        listItem.appendChild(header);
        listItem.appendChild(paragraph);

        unorderedList.appendChild(listItem);
      }
    );
  } else {
    document.getElementById("hits").innerHTML = "No hits found!";
  }
};

export default handleResults;
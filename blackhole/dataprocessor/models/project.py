# models.py

from django.db import models


class Organization(models.Model):
    name = models.CharField(max_length=255)


class Project(models.Model):
    name = models.CharField(max_length=255)


class Metadata(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE)
    key = models.CharField(max_length=255)
    value = models.TextField()


class Event(models.Model):
    metadata = models.ForeignKey(Metadata, on_delete=models.CASCADE)
    description = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)


def event_list(request):
    events = Event.objects.all()
    response = []
    for event in events:
        project = event.metadata.project
        organization = project.organization
        response.append(
            {
                "organization": organization.name,
                "project": project.name,
                "description": event.description,
                "timestamp": event.timestamp,
            }
        )
    return response

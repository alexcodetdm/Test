package com.askusu.newproject.rest.NavObject;

import com.askusu.newproject.ao.NavObject.ObjectType;
import com.askusu.newproject.rest.NavObject.NavObject_TableListWrapper;
import com.askusu.newproject.service.ErrorResponse;
import com.askusu.newproject.service.NavObject.NavObject_Service;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import com.atlassian.jira.component.ComponentAccessor;
import com.atlassian.jira.issue.ModifiedValue;
import com.atlassian.jira.issue.MutableIssue;
import java.sql.Timestamp;
import com.atlassian.jira.event.type.EventDispatchOption;
import java.sql.Date;
import java.util.Optional;

import com.atlassian.jira.issue.customfields.manager.OptionsManager;
import com.atlassian.jira.issue.customfields.option.Option;
import com.atlassian.jira.issue.Issue;
import com.atlassian.jira.issue.customfields.option.Options;
import com.atlassian.jira.issue.fields.CustomField;
import com.atlassian.jira.issue.fields.config.FieldConfig;
import com.atlassian.jira.issue.label.Label;
import com.atlassian.jira.bc.user.search.UserSearchService;
import com.atlassian.jira.bc.user.search.UserSearchParams;
import com.atlassian.jira.issue.util.DefaultIssueChangeHolder;
import com.atlassian.jira.user.ApplicationUser;
/**
 * A resource of message.
 */
@Path("/navobject-table/data")
@Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
@Consumes({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
public class NavObject_Table {
    private final NavObject_Service navObjectService;

    public NavObject_Table(NavObject_Service navObjectService) {
        this.navObjectService = navObjectService;
    }


    @POST
    public Response postData(NavObject_TableListWrapper wrapper) {
        com.askusu.newproject.ao.NavObject.NavObject_Table navObjectTable;
        try
        {
            navObjectTable = navObjectService.addTableData(wrapper.getNavObjectTableAdd());
        }
        catch (Exception ex)
        {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), ex))
                    .type(MediaType.APPLICATION_JSON)
                    .build();
        }
        //wrapper.clear();
        //wrapper.setNavObjectTableAfterAdd(navObjectTable);
        return Response.ok(wrapper).build();
    }

    @POST
    @Path("/data2")
    public Response postData2(String input) {
        try
        {
            System.out.println(input);
            MutableIssue issue = ComponentAccessor.getIssueManager().getIssueByCurrentKey("TEST-1"); // Номер задачи

            CustomField field01 = ComponentAccessor.getCustomFieldManager().getCustomFieldObjectByName("Объект по команде");
            CustomField field02 = ComponentAccessor.getCustomFieldManager().getCustomFieldObjectByName("Ролевая модель");

            //ModifiedValue newValue = new ModifiedValue(issue.getCustomFieldValue(field01), "Да");
            //System.out.println(newValue);
            //field01.updateValue(null, issue, newValue, new DefaultIssueChangeHolder());
            //issue.setCustomFieldValue(release01, "R222");
            //field01.updateValue(null, issue, new ModifiedValue(issue.getCustomFieldValue(field01),field01.getOptions(issue, field01, ["option 1"]).get(0)), new DefaultIssueChangeHolder());
            //System.out.println(field01.getOptions(issue, field01, ["option 1"]).get(0));

            List<Option> optionsList01 = new ArrayList<>();
            FieldConfig fieldConfig01 = field01.getRelevantConfig(issue);
            OptionsManager optionManager = ComponentAccessor.getOptionsManager();
            Options platOptions01 = optionManager.getOptions(fieldConfig01);

            List<Option> optionsList02 = new ArrayList<>();
            FieldConfig fieldConfig02 = field02.getRelevantConfig(issue);
            Options platOptions02 = optionManager.getOptions(fieldConfig02);

            System.out.println("9");
            /*
            for(int i = 0;i<platOptions.size();i++){
                String optVal = platOptions.get(i).getValue();
                System.out.println(optVal);
                //if(platOptions.get(i).getValue().equals("custom field value")){
                optionsList.add(platOptions.get(i));
                //    break;
                //}
            }
            */
            optionsList01.add(platOptions01.get(0));
            optionsList02.add(platOptions02.get(0));
            //field01.updateValue(null, issue, new ModifiedValue(issue.getCustomFieldValue(field01),optionsList01), new DefaultIssueChangeHolder());
            //field02.updateValue(null, issue, new ModifiedValue(issue.getCustomFieldValue(field02),optionsList02), new DefaultIssueChangeHolder());

            field01.updateValue(null, issue, new ModifiedValue(issue.getCustomFieldValue(field01),null), new DefaultIssueChangeHolder());
            field02.updateValue(null, issue, new ModifiedValue(issue.getCustomFieldValue(field02),null), new DefaultIssueChangeHolder());

            //issue.setCustomFieldValue(field01, "Да");
            //issue.setCustomFieldValue(field02, "Да");

            System.out.println("field01");
            System.out.println(issue.getCustomFieldValue(field01));
            System.out.println("field02");
            System.out.println(issue.getCustomFieldValue(field02));
            //field02.updateValue(null, issue, new ModifiedValue("", (Object) "Да"), new DefaultIssueChangeHolder());
            //System.out.println("field01");
            //issue.setResolutionObject(getConstantsManager().getResolutionObject("1")); // Резолюция (возможно: null)
            //issue.setOriginalEstimate((long) (32*60*60)); // Оценка
            //issue.setTimeSpent((long) 24*60*60); // Затрачено
            //issue.setEstimate((long) 8*60*60); // Осталось
            issue.setDescription("TEST-1 Description 4");
            //issue.setCreated(new Timestamp(117,5,26,8,0,0,0)); // Дата создания (год - 1900/месяц - 1/день/часы/минуты/секунды/наносекунды)
            //issue.setUpdated(new Timestamp(117,5,26,8,0,0,0)); // Дата обновления (год - 1900/месяц - 1/день/часы/минуты/секунды/наносекунды)
            //issue.setAssignee(ComponentAccessor.getUserUtil().getUserByName("akrotov").getDirectoryUser()); // Устанавливаем исполнителя
            //issue.setReporter(ComponentAccessor.getUserUtil().getUserByName("akrotov").getDirectoryUser()); // Устанавливаем автора
            //ComponentAccessor.getChangeHistoryManager().removeAllChangeItems(issue); // Удалить историю
            issue.store(); // Применить изменения
        }
        catch (Exception ex)
        {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), ex))
                    .type(MediaType.APPLICATION_JSON)
                    .build();
        }

        return Response.ok().build();
    }

    @DELETE
    public Response deleteData(@QueryParam("ID") Integer id)
    {
        try {
            navObjectService.deleteTableData(id);
        }
        catch (Exception ex){
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), ex))
                    .type(MediaType.APPLICATION_JSON)
                    .build();
        }
        return Response.ok().build();
    }
}